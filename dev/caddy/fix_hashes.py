#!/usr/bin/env python

import subprocess
import sys
import os
import re
import logging
import tempfile


def strip_ansi_codes(text):
    # Improved ANSI escape sequence regex, with global and multiline behavior
    ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])", re.MULTILINE)
    return ansi_escape.sub("", text)


def find_hashes_in_log(log):
    """
    Looks for a line containing 'hash mismatch in fixed-output derivation'
    and extracts the hashes from the following cleaned lines.
    Returns (current_hash, expected_hash, cleaned_block) or (None, None, cleaned_block) if not found.
    """
    lines = log.splitlines()
    for i, line in enumerate(lines):
        if "hash mismatch in fixed-output derivation" in line:
            # If the line contains unicode-escaped sequences, decode them
            try:
                decoded_line = line.encode("utf-8").decode("unicode_escape")
            except Exception:
                decoded_line = line
            # Gather the block: this line + a few after, decode unicode escapes in each
            block = [decoded_line]
            for j in range(i + 1, min(i + 8, len(lines))):
                l = lines[j]
                try:
                    l = l.encode("utf-8").decode("unicode_escape")
                except Exception:
                    pass
                block.append(l)
            # Now strip ANSI codes for searching and display
            cleaned_block = [strip_ansi_codes(l) for l in block]
            current = expected = None
            # Regex, with global (find all) and multiline flags
            specified_re = re.compile(
                r"^\s*specified:\s*(sha256-[A-Za-z0-9+/=]+)", re.MULTILINE
            )
            got_re = re.compile(r"^\s*got:\s*(sha256-[A-Za-z0-9+/=]+)", re.MULTILINE)
            for l_stripped in cleaned_block:
                m1 = specified_re.search(l_stripped)
                if m1:
                    current = m1.group(1)
                m2 = got_re.search(l_stripped)
                if m2:
                    expected = m2.group(1)
            return current, expected, cleaned_block
    return None, None, []


def find_nix_file_with_hash(hash_val):
    for root, _, files in os.walk("."):
        for fname in files:
            if fname.endswith(".nix"):
                path = os.path.join(root, fname)
                try:
                    with open(path, encoding="utf-8") as f:
                        if hash_val in f.read():
                            return path
                except Exception:
                    continue
    return None


def update_hash_in_file(file_path, old_hash, new_hash):
    with open(file_path, encoding="utf-8") as f:
        content = f.read()
    new_content = content.replace(old_hash, new_hash)
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)


def main():
    logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")

    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <command> [args...]")
        sys.exit(1)

    cmd = sys.argv[1:]
    logging.info("Running build command: %s", " ".join(cmd))
    env = dict(os.environ)
    env["NO_COLOR"] = "1"
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, env=env)
        output = proc.stdout + proc.stderr
    except Exception as e:
        logging.error("Failed to run command: %s", e)
        sys.exit(1)

    # Save full log for debugging
    with tempfile.NamedTemporaryFile(
        delete=False, mode="w", encoding="utf-8", suffix=".log", prefix="build-log-"
    ) as tmpf:
        tmpf.write(output)
        raw_log_path = tmpf.name

    current_hash, expected_hash, cleaned_block = find_hashes_in_log(output)

    # Also save a cleaned version of the relevant block, if found
    cleaned_log_file_path = None
    if cleaned_block:
        cleaned_block_joined = "\n".join(cleaned_block)
        with tempfile.NamedTemporaryFile(
            delete=False,
            mode="w",
            encoding="utf-8",
            suffix=".cleaned.log",
            prefix="build-log-",
        ) as tmpf:
            tmpf.write(cleaned_block_joined)
            cleaned_log_file_path = tmpf.name

    if not current_hash or not expected_hash:
        logging.error("Could not extract both current and expected hashes from output.")
        logging.error("Full raw build log written to %s", raw_log_path)
        if cleaned_block:
            print("Cleaned relevant log block:")
            print("\n".join(cleaned_block))
            if cleaned_log_file_path:
                logging.error("Cleaned build log written to %s", cleaned_log_file_path)
        sys.exit(1)

    logging.info("Current hash:  %s", current_hash)
    logging.info("Expected hash: %s", expected_hash)

    nix_file = find_nix_file_with_hash(current_hash)
    if not nix_file:
        logging.error(
            "No .nix file found containing the current hash: %s", current_hash
        )
        if cleaned_log_file_path:
            logging.error("Cleaned build log written to %s", cleaned_log_file_path)
        sys.exit(1)

    update_hash_in_file(nix_file, current_hash, expected_hash)
    logging.info(
        "Updated %s: replaced %s with %s", nix_file, current_hash, expected_hash
    )
    if cleaned_log_file_path:
        logging.info("Cleaned build log written to %s", cleaned_log_file_path)


if __name__ == "__main__":
    main()

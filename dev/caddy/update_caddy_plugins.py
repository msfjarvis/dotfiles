#!/usr/bin/env python3
"""
Update Caddy plugins to their latest versions and fix Nix hashes.

This script automatically updates Caddy plugin versions in the Nix configuration
by fetching the latest commits from their Git repositories.

Features:
- Automatically updates plugins to their latest pseudo-versions
- Pin plugins to specific versions by adding a comment containing "pinned"
  Example: "pkg.example.com/plugin@v0.0.0-..." # pinned
- Automatically fixes Nix hash mismatches
- Supports dry-run mode to preview changes
- Can add new plugins via --add-plugin flag
"""

import sys
import tempfile
import shutil
import subprocess
import datetime
import urllib.request
import re
import logging
import os
import argparse
from pathlib import Path


def setup_logging(level=logging.INFO):
    logging.basicConfig(
        level=level,
        format="[%(asctime)s] %(levelname)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def strip_ansi_codes(text):
    """Remove ANSI escape sequences from text."""
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


def fetch_go_import_meta(import_path):
    """Fetch go-import meta tags for vanity imports."""
    segments = import_path.split("/")
    for i in range(len(segments), 0, -1):
        prefix = "/".join(segments[:i])
        url = f"https://{prefix}?go-get=1"
        logging.debug(f"Trying vanity meta discovery at: {url}")
        try:
            with urllib.request.urlopen(url, timeout=10) as resp:
                html = resp.read().decode("utf-8")
                logging.info(f"Fetched go-import meta HTML from {url}")
                return prefix, html
        except Exception as e:
            logging.warning(f"Failed to fetch {url}: {e}")
            continue
    logging.error("Could not fetch ?go-get=1 page for the import path.")
    return None, None


def parse_go_import_meta(import_path, html):
    """Parse go-import meta tags to find git repository URL."""
    meta_tags = re.findall(r'<meta\s+name="go-import"\s+content="([^"]+)"', html)
    best_match = None
    best_len = -1
    for tag in meta_tags:
        fields = tag.split()
        if len(fields) != 3:
            continue
        prefix, vcs, repo_url = fields
        if vcs != "git":
            continue
        if import_path == prefix or import_path.startswith(prefix + "/"):
            if len(prefix) > best_len:
                best_match = (prefix, repo_url)
                best_len = len(prefix)
    if best_match:
        logging.info(f"Matched vanity prefix '{best_match[0]}', repo: {best_match[1]}")
    else:
        logging.error('No valid <meta name="go-import"> found for this import path.')
    return best_match


def infer_git_url(pkg_path):
    """Infer git repository URL from Go import path."""
    host = pkg_path.split("/")[0]
    if host in ("github.com", "gitlab.com", "bitbucket.org"):
        parts = pkg_path.split("/")
        if len(parts) >= 3:
            url = "https://" + "/".join(parts[:3]) + ".git"
            logging.info(f"Directly inferred repo URL: {url}")
            return url
    prefix, html = fetch_go_import_meta(pkg_path)
    if not html:
        return None
    match = parse_go_import_meta(pkg_path, html)
    if not match:
        return None
    return match[1]


def get_commit_info(repo_dir):
    """Get latest commit hash and timestamp from a git repository."""
    try:
        commit_hash = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=repo_dir, text=True
        ).strip()
        commit_ts = int(
            subprocess.check_output(
                ["git", "show", "-s", "--format=%ct", "HEAD"], cwd=repo_dir, text=True
            ).strip()
        )
        logging.info(f"HEAD commit: {commit_hash}, timestamp: {commit_ts}")
        return commit_hash, commit_ts
    except Exception as e:
        logging.error(f"Unable to get commit info: {e}")
        return None, None


def get_latest_pseudo_version(pkg_path):
    """Get the latest pseudo-version for a Go package."""
    logging.info(f"Getting latest version for: {pkg_path}")

    repo_url = infer_git_url(pkg_path)
    if not repo_url:
        logging.error(f"Could not determine repository URL for {pkg_path}")
        return None

    logging.info(f"Using repository URL: {repo_url}")

    tmpdir = tempfile.mkdtemp(prefix="go-pseudo-ver-")
    try:
        subprocess.check_call(
            ["git", "clone", "--quiet", "--depth=1", repo_url, tmpdir],
            stderr=subprocess.DEVNULL,
        )
        logging.info("Clone complete.")

        commit_hash, commit_ts = get_commit_info(tmpdir)
        if not commit_hash or not commit_ts:
            return None

        commit_dt = datetime.datetime.fromtimestamp(commit_ts, datetime.UTC)
        timestamp_str = commit_dt.strftime("%Y%m%d%H%M%S")
        version = f"v0.0.0-{timestamp_str}-{commit_hash[:12]}"

        logging.info(f"Latest pseudo-version for {pkg_path}: {version}")
        return version
    except subprocess.CalledProcessError as e:
        logging.error(f"Git command failed for {pkg_path}: {e}")
        return None
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def parse_caddy_plugins_file(file_path):
    """Parse the Caddy plugins Nix file to extract plugins and hash."""
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract plugins list
    plugins_match = re.search(r"plugins\s*=\s*\[(.*?)\];", content, re.DOTALL)
    if not plugins_match:
        logging.error("Could not find plugins list in file")
        return None, None, content

    plugins_text = plugins_match.group(1)
    # Match plugin line with optional comment
    plugin_pattern = r'"([^"@]+)@([^"]+)"(?:\s*#\s*(.*))?'
    plugins = []

    for match in re.finditer(plugin_pattern, plugins_text):
        pkg_path = match.group(1)
        current_version = match.group(2)
        comment = match.group(3).strip() if match.group(3) else None
        # Check if plugin is pinned (using negative lookbehind/lookahead to avoid "unpinned")
        is_pinned = bool(comment and re.search(r'(?<![a-zA-Z])pinned(?![a-zA-Z])', comment, re.IGNORECASE))
        plugins.append((pkg_path, current_version, is_pinned, comment))

    # Extract current hash
    hash_match = re.search(r'hash\s*=\s*"([^"]+)"', content)
    current_hash = hash_match.group(1) if hash_match else None

    logging.info(f"Found {len(plugins)} plugins and hash: {current_hash}")
    return plugins, current_hash, content


def update_plugins_file(file_path, content, updated_plugins, new_hash=None):
    """Update the Nix file with new plugin versions and optionally new hash."""
    new_content = content

    # Update plugins
    plugins_list = []
    for item in updated_plugins:
        if len(item) == 4:
            pkg_path, version, is_pinned, comment = item
            line = f'    "{pkg_path}@{version}"'
            if comment:
                line += f" # {comment}"
            plugins_list.append(line)
        else:
            # Legacy support for tuples without comment
            pkg_path, version = item
            plugins_list.append(f'    "{pkg_path}@{version}"')

    plugins_text = "[\n" + "\n".join(plugins_list) + "\n  ]"
    new_content = re.sub(
        r"plugins\s*=\s*\[.*?\];",
        f"plugins = {plugins_text};",
        new_content,
        flags=re.DOTALL,
    )

    # Update hash if provided
    if new_hash:
        new_content = re.sub(
            r'hash\s*=\s*"[^"]+";', f'hash = "{new_hash}";', new_content
        )

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)


def build_and_fix_hash(nix_file_path, build_cmd):
    """Build the Nix derivation and fix hash mismatches."""
    max_attempts = 3
    attempt = 0

    while attempt < max_attempts:
        attempt += 1
        logging.info(f"Build attempt {attempt}/{max_attempts}")

        env = dict(os.environ)
        env["NO_COLOR"] = "1"

        try:
            proc = subprocess.run(build_cmd, capture_output=True, text=True, env=env)
            output = proc.stdout + proc.stderr

            if proc.returncode == 0:
                logging.info("Build successful!")
                return True

            # Check for hash mismatch
            current_hash, expected_hash, cleaned_block = find_hashes_in_log(output)

            if not current_hash or not expected_hash:
                logging.error("Build failed but no hash mismatch found.")
                logging.error("Build output:")
                print(output)
                return False

            logging.info(f"Hash mismatch detected:")
            logging.info(f"  Current:  {current_hash}")
            logging.info(f"  Expected: {expected_hash}")

            # Read current file content
            with open(nix_file_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Update hash
            new_content = content.replace(current_hash, expected_hash)

            with open(nix_file_path, "w", encoding="utf-8") as f:
                f.write(new_content)

            logging.info(f"Updated hash in {nix_file_path}")

        except Exception as e:
            logging.error(f"Build command failed: {e}")
            return False

    logging.error(f"Failed to build after {max_attempts} attempts")
    return False


def main():
    parser = argparse.ArgumentParser(
        description="Update Caddy plugins to their latest versions and fix Nix hashes",
        epilog="""
Examples:
  %(prog)s                    # Update all plugins to latest versions
  %(prog)s --dry-run          # Show what would be updated
  %(prog)s --force            # Force rebuild even if no updates
  %(prog)s --verbose          # Enable detailed logging
  %(prog)s --file /path/to/default.nix  # Use specific file
  %(prog)s --add-plugin github.com/user/plugin  # Add new plugin

Pin plugins to specific versions:
  Add a comment containing "pinned" at the end of a plugin line to prevent updates:
  "pkg.example.com/plugin@v0.0.0-20231201120000-abc123def456" # pinned
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--force",
        "-f",
        action="store_true",
        help="Force rebuild even if no updates are found",
    )
    parser.add_argument(
        "--dry-run",
        "-n",
        action="store_true",
        help="Show what would be updated without making changes",
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Enable verbose logging"
    )
    parser.add_argument(
        "--file",
        type=Path,
        help="Path to caddy-with-plugins/default.nix file (auto-detected if not specified)",
    )
    parser.add_argument(
        "--add-plugin",
        type=str,
        help="Add a new plugin by Go import path (e.g. github.com/user/plugin)",
    )

    args = parser.parse_args()

    # Setup logging with appropriate level
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="[%(asctime)s] %(levelname)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # Find the caddy-with-plugins file
    if args.file:
        caddy_file = args.file
        dotfiles_root = caddy_file.parent.parent.parent
    else:
        script_dir = Path(__file__).parent
        dotfiles_root = script_dir.parent.parent
        caddy_file = dotfiles_root / "packages" / "caddy-with-plugins" / "default.nix"

    if not caddy_file.exists():
        logging.error(f"Caddy plugins file not found: {caddy_file}")
        sys.exit(1)

    logging.info(f"Processing Caddy plugins file: {caddy_file}")
    if args.dry_run:
        logging.info("DRY RUN MODE - No changes will be made")

    # Change to dotfiles root directory for building
    original_cwd = os.getcwd()
    os.chdir(dotfiles_root)

    try:
        # Parse current plugins
        plugins, current_hash, content = parse_caddy_plugins_file(caddy_file)
        if plugins is None:
            sys.exit(1)

        # Add new plugin if specified
        if args.add_plugin:
            logging.info(f"Adding new plugin: {args.add_plugin}")
            latest_version = get_latest_pseudo_version(args.add_plugin)
            if latest_version:
                # Check if plugin already exists
                existing_plugins = [pkg_path for pkg_path, *_ in plugins]
                if args.add_plugin not in existing_plugins:
                    plugins.append((args.add_plugin, latest_version, False, None))
                    logging.info(f"Added {args.add_plugin}@{latest_version}")
                else:
                    logging.warning(
                        f"Plugin {args.add_plugin} already exists, will be updated instead"
                    )
            else:
                logging.error(
                    f"Could not get version for new plugin: {args.add_plugin}"
                )
                sys.exit(1)

        # Update each plugin to latest version
        updated_plugins = []
        updates_made = False

        for pkg_path, current_version, is_pinned, comment in plugins:
            logging.info(f"Checking plugin: {pkg_path}")
            logging.info(f"Current version: {current_version}")
            
            if is_pinned:
                logging.info(f"Plugin {pkg_path} is pinned, skipping update")
                updated_plugins.append((pkg_path, current_version, is_pinned, comment))
                continue

            latest_version = get_latest_pseudo_version(pkg_path)
            if not latest_version:
                logging.warning(
                    f"Could not get latest version for {pkg_path}, keeping current"
                )
                updated_plugins.append((pkg_path, current_version, is_pinned, comment))
                continue

            if latest_version != current_version:
                logging.info(
                    f"Updating {pkg_path}: {current_version} -> {latest_version}"
                )
                updated_plugins.append((pkg_path, latest_version, is_pinned, comment))
                updates_made = True
            else:
                logging.info(f"No update needed for {pkg_path}")
                updated_plugins.append((pkg_path, current_version, is_pinned, comment))

        if not updates_made and not args.force and not args.add_plugin:
            logging.info("No plugin updates needed!")
            if not args.force:
                logging.info("Use --force to rebuild anyway")
                return

        if args.dry_run:
            # Show what would be updated
            print("\n" + "=" * 60)
            print("DRY RUN - PROPOSED CHANGES")
            print("=" * 60)
            for pkg_path, version, is_pinned, comment in updated_plugins:
                original_version = next(v for p, v, *_ in plugins if p == pkg_path)
                if is_pinned:
                    print(f"📌 {pkg_path} (pinned)")
                    print(f"   {version}")
                elif version != original_version:
                    print(f"📝 {pkg_path}")
                    print(f"   {original_version} -> {version}")
                else:
                    print(f"⚪ {pkg_path} (no change)")
            print("=" * 60)
            print("Run without --dry-run to apply these changes")
            return

        # Update the file with new plugin versions
        if updates_made or args.force or args.add_plugin:
            logging.info("Updating plugins file with new versions...")
            update_plugins_file(caddy_file, content, updated_plugins)

            # Build and fix hashes
            logging.info("Building and fixing hashes...")
            build_cmd = ["nix", "build", "-f", ".", "caddy-with-plugins", "--no-link"]

            if build_and_fix_hash(caddy_file, build_cmd):
                logging.info("✅ Successfully updated all Caddy plugins!")

                # Show summary
                print("\n" + "=" * 60)
                print("PLUGIN UPDATE SUMMARY")
                print("=" * 60)
                for pkg_path, version, is_pinned, comment in updated_plugins:
                    original_version = next(v for p, v, *_ in plugins if p == pkg_path)
                    if is_pinned:
                        print(f"📌 {pkg_path} (pinned)")
                        print(f"   {version}")
                    elif version != original_version:
                        print(f"✅ {pkg_path}")
                        print(f"   {original_version} -> {version}")
                    else:
                        print(f"⚪ {pkg_path} (no change)")
                print("=" * 60)
            else:
                logging.error("❌ Failed to build with updated plugins")
                # Restore original file on failure
                logging.info("Restoring original file...")
                update_plugins_file(caddy_file, content, plugins)
                sys.exit(1)
    finally:
        os.chdir(original_cwd)


if __name__ == "__main__":
    main()

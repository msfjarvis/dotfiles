#!/usr/bin/env python

import sys
import tempfile
import shutil
import subprocess
import datetime
import urllib.request
import re
import logging


def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="[%(asctime)s] %(levelname)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def usage():
    print(f"Usage: {sys.argv[0]} <go-package-path>")
    sys.exit(1)


def fetch_go_import_meta(import_path):
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
    host = pkg_path.split("/")[0]
    if host in ("github.com", "gitlab.com", "bitbucket.org"):
        parts = pkg_path.split("/")
        if len(parts) >= 3:
            url = "https://" + "/".join(parts[:3]) + ".git"
            logging.info(f"Directly inferred repo URL: {url}")
            return url
    prefix, html = fetch_go_import_meta(pkg_path)
    if not html:
        sys.exit(1)
    match = parse_go_import_meta(pkg_path, html)
    if not match:
        sys.exit(1)
    return match[1]


def get_commit_info(repo_dir):
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
        sys.exit(1)


def main():
    setup_logging()
    if len(sys.argv) != 2:
        usage()
    pkg_path = sys.argv[1]
    logging.info(f"Resolving repository for import path: {pkg_path}")

    repo_url = infer_git_url(pkg_path)
    logging.info(f"Using repository URL: {repo_url}")

    tmpdir = tempfile.mkdtemp(prefix="go-pseudo-ver-")
    logging.info(f"Cloning repository to temp dir: {tmpdir}")
    try:
        subprocess.check_call(
            ["git", "clone", "--quiet", "--depth=1", repo_url, tmpdir]
        )
        logging.info("Clone complete.")
        commit_hash, commit_ts = get_commit_info(tmpdir)
        commit_dt = datetime.datetime.fromtimestamp(commit_ts, datetime.UTC)
        timestamp_str = commit_dt.strftime("%Y%m%d%H%M%S")
        version = f"v0.0.0-{timestamp_str}-{commit_hash[:12]}"
        pretty_result = f"\n\033[1;32m{pkg_path}@{version}\033[0m\n"
        print(pretty_result)
        logging.info(f"Pseudo-version: {version}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Git command failed: {e}")
        sys.exit(1)
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)
        logging.info(f"Cleaned up temp dir: {tmpdir}")


if __name__ == "__main__":
    main()

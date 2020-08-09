#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

set -euo pipefail

trap "rm -f /tmp/zulu_jdk.deb 2>/dev/null" INT TERM EXIT

# shellcheck source=common
source "${SCRIPT_DIR:?}"/common

ZULU_PACKAGE_URL="https://cdn.azul.com/zulu/bin/zulu14.27.1-ca-jdk14-linux_amd64.deb"
ZULU_PACKAGE_CHECKSUM="16a7bad82c0f427f1896ec42914b67f5fc0b7841859c3b61b776c30773b44e78"

function download_jdk() {
  aria2c "${ZULU_PACKAGE_URL}" -d "/tmp" -o "zulu_jdk.deb"
}

function verify_checksum() {
  if [[ "$(sha256sum /tmp/zulu_jdk.deb | awk '{print $1}')" != "${ZULU_PACKAGE_CHECKSUM}" ]]; then
    return 1
  else
    return 0
  fi
}

function check_and_install_jdk() {
  echoText "Checking and installing Zulu JDK"
  [ "$(java -version 2>&1 | head -n1 | sed 's/.*\"\(.*\)\"/\1/g')" == "14 2020-03-17" ] && {
    reportWarning "Latest version of Zulu JDK already installed"
    return 0
  }
  [ -f "/tmp/zulu_jdk.deb" ] && rm -f "/tmp/zulu_jdk.deb"
  download_jdk
  if verify_checksum; then
    sudo dpkg -i "/tmp/zulu_jdk.deb"
  else
    reportError "Package checksum verification failed!"
    return 1
  fi
  rm -f "/tmp/zulu_jdk.deb" 2>/dev/null
}

check_and_install_jdk

#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap "rm -f /tmp/zulu_jdk.deb 2>/dev/null" INT TERM EXIT
source "${SCRIPT_DIR:?}"/common

ZULU_PACKAGE_URL="https://cdn.azul.com/zulu/bin/zulu8.40.0.25-ca-jdk8.0.222-linux_amd64.deb"
ZULU_PACKAGE_CHECKSUM="6489b1af75b398f661df3ab68b68b0d4f3dbeafc785337db175a53709faa5f0f"

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
    [ "$(java -version 2>&1 | head -n1 | sed 's/.*\"\(.*\)\"/\1/g')" == "1.8.0_222" ] && {
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

#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm -rf /tmp/xclip' INT TERM EXIT

SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
source "${SCRIPT_DIR}"/../common
source "${SCRIPT_DIR}"/../gitshit

function install_xclip {
    local XCLIP_VER LATEST_XCLIP_VER TMPFILE SCRIPT_DIR; TMPFILE="$(mktemp)"
    echoText "Checking and installing xclip"
    xclip -version 2>"${TMPFILE}"
    XCLIP_VER="$(grep version "${TMPFILE}" | awk '{print $3}')"
    LATEST_XCLIP_VER="$(get_latest_release astrand/xclip)"
    if [ "${XCLIP_VER}" != "${LATEST_XCLIP_VER}" ]; then
        echoText "Building latest xclip version from git"
        cd /tmp || return 1
        git clone https://github.com/astrand/xclip
        cd xclip || return 1
        autoreconf
        ./configure
        make all -j"$(nproc)"
        sudo make install install.man
    else
        echoText "Latest xclip version is installed"
    fi
    rm "${TMPFILE}"
    rm -rf /tmp/xclip 2>/dev/null
}

install_xclip
#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm -rf /tmp/xclip 2>/dev/null' INT TERM EXIT

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function install_xclip() {
    local XCLIP_VER LATEST_XCLIP_VER SCRIPT_DIR
    echoText "Checking and installing xclip"
    XCLIP_VER="$(xclip -version 2>&1 | head -n1 | awk '{print $3}')"
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
        reportWarning "xclip ${XCLIP_VER} is already installed!"
    fi
    rm -rf /tmp/xclip 2>/dev/null
}

install_xclip

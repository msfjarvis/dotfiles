#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function check_and_install_bat() {
    local BAT BAT_ARTIFACT LOCAL_BAT_VERSION REMOTE_BAT_VERSION
    BAT="$(command -v bat)"
    echoText "Checking and installing bat"
    if [ -z "${BAT}" ]; then
        install_bat
    else
        LOCAL_BAT_VERSION="$(bat --version | awk '{print $2}')"
        REMOTE_BAT_VERSION="$(get_latest_release sharkdp/bat | sed 's/v//')"
        if [ "${LOCAL_BAT_VERSION}" != "${REMOTE_BAT_VERSION}" ]; then
            reportWarning "Outdated version of bat detected, upgrading"
            install_bat
        else
            reportWarning "$(bat --version) is already installed!"
        fi
    fi
}

function install_bat() {
    local BAT_ARTIFACT
    BAT_ARTIFACT="bat_.*_amd64.deb"
    cd /tmp || return 1
    aria2c "$(get_release_assets sharkdp/bat | grep "${BAT_ARTIFACT}")" -o bat.deb
    sudo dpkg -i bat.deb
    rm -rf bat.deb
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_bat

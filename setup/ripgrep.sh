#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/ripgrep.deb 2>/dev/null' INT TERM EXIT

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function check_and_install_ripgrep() {
    local RIPGREP RIPGREP_ARTIFACT LOCAL_RIPGREP_VERSION REMOTE_RIPGREP_VERSION
    RIPGREP="$(command -v rg)"
    echoText "Checking and installing ripgrep"
    if [ -z "${RIPGREP}" ]; then
        install_ripgrep
    else
        LOCAL_RIPGREP_VERSION="$(rg --version | head -n1 | awk '{print $2}')"
        REMOTE_RIPGREP_VERSION="$(get_latest_release BurntSushi/ripgrep)"
        if [ "${LOCAL_RIPGREP_VERSION}" != "${REMOTE_RIPGREP_VERSION}" ]; then
            reportWarning "Outdated version of ripgrep detected, upgrading"
            install_ripgrep
        else
            reportWarning "$(rg --version | head -n1) is already installed!"
        fi
    fi
}

function install_ripgrep() {
    local RIPGREP_ARTIFACT
    RIPGREP_ARTIFACT="ripgrep_.*_amd64.deb"
    cd /tmp || return 1
    aria2c "$(get_release_assets BurntSushi/ripgrep | grep "${RIPGREP_ARTIFACT}")" -o ripgrep.deb
    sudo dpkg -i ripgrep.deb
    rm -rf ripgrep.deb 2>/dev/null
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_ripgrep

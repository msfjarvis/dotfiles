#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/diskus.deb 2>/dev/null' INT TERM EXIT

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function check_and_install_diskus() {
    local DISKUS DISKUS_ARTIFACT LOCAL_DISKUS_VERSION REMOTE_DISKUS_VERSION
    DISKUS="$(command -v diskus)"
    echoText "Checking and installing diskus"
    if [ -z "${DISKUS}" ]; then
        install_diskus
    else
        LOCAL_DISKUS_VERSION="$(diskus --version | awk '{print $2}')"
        REMOTE_DISKUS_VERSION="$(get_latest_release sharkdp/diskus | sed 's/v//')"
        if [ "${LOCAL_DISKUS_VERSION}" != "${REMOTE_DISKUS_VERSION}" ]; then
            reportWarning "Outdated version of diskus detected, upgrading"
            install_diskus
        else
            reportWarning "$(diskus --version) is already installed!"
        fi
    fi
}

function install_diskus() {
    local DISKUS_ARTIFACT
    DISKUS_ARTIFACT="diskus_.*_amd64.deb"
    cd /tmp || return 1
    aria2c "$(get_release_assets sharkdp/diskus | grep "${DISKUS_ARTIFACT}")" -o diskus.deb
    sudo dpkg -i diskus.deb
    rm -rf diskus.deb 2>/dev/null
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_diskus

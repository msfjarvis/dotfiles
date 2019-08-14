#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/fd.deb' INT TERM EXIT

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function check_and_install_fd() {
    local FD FD_ARTIFACT LOCAL_FD_VERSION REMOTE_FD_VERSION
    FD="$(command -v fd)"
    echoText "Checking and installing fd"
    if [ -z "${FD}" ]; then
        install_fd
    else
        LOCAL_FD_VERSION="$(fd --version | awk '{print $2}')"
        REMOTE_FD_VERSION="$(get_latest_release sharkdp/fd | sed 's/v//')"
        if [ "${LOCAL_FD_VERSION}" != "${REMOTE_FD_VERSION}" ]; then
            reportWarning "Outdated version of fd detected, upgrading"
            install_fd
        else
            reportWarning "$(fd --version) is already installed!"
        fi
    fi
}

function install_fd() {
    local FD_ARTIFACT
    FD_ARTIFACT="fd_.*_amd64.deb"
    cd /tmp || return 1
    aria2c "$(get_release_assets sharkdp/fd | grep "${FD_ARTIFACT}")" -o fd.deb
    sudo dpkg -i fd.deb
    rm -rf fd.deb
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_fd

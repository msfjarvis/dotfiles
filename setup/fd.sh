#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}"/common
source "${SCRIPT_DIR}"/gitshit

function install_fd {
    local FD FD_ARTIFACT
    echoText "Checking and installing fd"
    FD="$(command -v fd)"
    if [ "${FD}" == "" ]; then
        FD_ARTIFACT="fd_.*_amd64.deb"
        aria2c "$(get_release_assets sharkdp/fd | grep "${FD_ARTIFACT}")" -o fd.deb
        sudo dpkg -i fd.deb
        cd "${SCRIPT_DIR}" || return 1
        rm -rf fd.deb
    else
        reportWarning "$(fd --version) is already installed!"
    fi
}

install_fd

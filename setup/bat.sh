#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}"/common
source "${SCRIPT_DIR}"/gitshit

function install_bat {
    local BAT BAT_ARTIFACT
    echoText "Checking and installing bat"
    BAT="$(command -v bat)"
    if [ "${BAT}" == "" ]; then
        BAT_ARTIFACT="bat_.*_amd64.deb"
        aria2c "$(get_release_assets sharkdp/bat | grep "${BAT_ARTIFACT}")" -o bat.deb
        sudo dpkg -i bat.deb
        cd "${SCRIPT_DIR}" || return 1
        rm -rf bat.deb
    else
        reportWarning "$(bat --version) is already installed!"
    fi
}

install_bat

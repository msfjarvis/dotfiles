#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

function install_hub {
    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
    source "${SCRIPT_DIR}"/../common
    echoText "Checking and installing hub"
    HUB="$(command -v hub)"
    if [ "${HUB}" == "" ]; then
        HUB_ARCH=linux-amd64
        aria2c "$(get_release_assets github/hub | grep ${HUB_ARCH})" -o hub.tgz
        mkdir -p hub
        tar -xf hub.tgz -C hub
        sudo ./hub/*/install --prefix=/usr/local/
        rm -rf hub/ hub.tgz
    else
        reportWarning "$(hub --version) is already installed!"
    fi
}

install_hub

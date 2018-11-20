#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

function install_gdrive {
    local SCRIPT_DIR ARTIFACT_NAME; SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
    source "${SCRIPT_DIR}"/../common
    ARTIFACT_NAME="gdrive-linux-x64"
    if [ "$(command -v gdrive)" == "" ]; then
        echoText "Checking and installing gdrive"
        aria2c "$(get_release_assets MSF-Jarvis/gdrive | grep ${ARTIFACT_NAME})" --allow-overwrite=true -d ~/bin o gdrive
        chmod +x ~/bin/gdrive
    else
        INSTALLED_VERSION="$(gdrive version | grep gdrive | awk '{print $2}')"
        LATEST_VERSION="$(get_latest_release MSF-Jarvis/gdrive)"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            reportWarning "Outdated version of gdrive detected, upgrading"
            aria2c "$(get_release_assets MSF-Jarvis/gdrive | grep ${ARTIFACT_NAME})" --allow-overwrite=true -d ~/bin -o gdrive
            chmod +x ~/bin/gdrive
        else
            reportWarning "Latest version of gdrive is already installed!"
        fi
    fi
}

install_gdrive
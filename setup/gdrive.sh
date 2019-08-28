#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/gdrive' INT TERM EXIT

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function check_and_install_gdrive() {
    local GDRIVE ARTIFACT_NAME
    ARTIFACT_NAME="gdrive-linux-x64"
    echoText "Checking and installing gdrive"
    GDRIVE="$(command -v gdrive)"
    if [ -z "${GDRIVE}" ]; then
        install_gdrive
    else
        INSTALLED_VERSION="$(gdrive version | grep gdrive | awk '{print $2}')"
        LATEST_VERSION="$(get_latest_release gdrive-org/gdrive)"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            reportWarning "Outdated version of gdrive detected, upgrading"
            install_gdrive
        else
            reportWarning "gdrive ${INSTALLED_VERSION} is already installed!"
        fi
    fi
}

function install_gdrive() {
    aria2c "$(get_release_assets gdrive-org/gdrive | grep ${ARTIFACT_NAME})" --allow-overwrite=true -d ~/bin -o gdrive
    chmod +x ~/bin/gdrive
}

check_and_install_gdrive

#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=common
source "${SCRIPT_DIR:?}"/common
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install_ktlint() {
    local KTLINT INSTALLED_VERSION LATEST_VERSION
    KTLINT="$(command -v ktlint)"
    echoText "Checking and installing 'ktlint'"
    if [ -z "${KTLINT}" ]; then
        install_ktlint
    else
        INSTALLED_VERSION="$(ktlint --version)"
        LATEST_VERSION="$(get_latest_release pinterest/ktlint)"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            reportWarning "Outdated version of 'ktlint' detected"
            install_ktlint
        else
            reportWarning "'ktlint' ${INSTALLED_VERSION} is already installed!"
        fi
    fi
}

function install_ktlint() {
    cd /tmp || return 1
    aria2c "$(get_release_assets pinterest/ktlint | grep ktlint$)" -o ktlint
    sudo install ktlint /usr/local/bin/
    rm -f /tmp/ktlint
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_ktlint

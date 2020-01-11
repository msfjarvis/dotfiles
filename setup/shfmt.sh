#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install_shfmt() {
    local SHFMT INSTALLED_VERSION LATEST_VERSION
    SHFMT="$(command -v shfmt)"
    echoText "Checking and installing 'shfmt'"
    if [ -z "${SHFMT}" ]; then
        install_shfmt
    else
        INSTALLED_VERSION="$(shfmt --version)"
        LATEST_VERSION="$(get_latest_release mvdan/sh)"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            printUpgradeBanner "shfmt" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
            install_shfmt
        else
            printUpToDateBanner "shfmt" "${INSTALLED_VERSION}"
        fi
    fi
}

function install_shfmt() {
    cd /tmp || return 1
    aria2c "$(get_release_assets mvdan/sh | grep linux_amd64)" -o shfmt
    sudo install shfmt /usr/local/bin/
    rm -f /tmp/shfmt
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_shfmt

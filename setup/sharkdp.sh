#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap "rm /tmp/binary.deb 2>/dev/null" INT TERM EXIT

source "${SCRIPT_DIR:?}"/common
source "${SCRIPT_DIR}"/gitshit

function check_and_install() {
    local BIN BIN_NAME LOCAL_BIN_VERSION REMOTE_BIN_VERSION
    BIN_NAME="${1}"
    BIN="$(command -v "${BIN_NAME}")"
    echoText "Checking and installing ${BIN_NAME}"
    if [ -z "${BIN}" ]; then
        install "${BIN_NAME}"
    else
        LOCAL_BIN_VERSION="$(${BIN_NAME} --version | awk '{print $2}')"
        REMOTE_BIN_VERSION="$(get_latest_release sharkdp/"${BIN_NAME}" | sed 's/v//')"
        if [ "${LOCAL_BIN_VERSION}" != "${REMOTE_BIN_VERSION}" ]; then
            reportWarning "Outdated version of ${BIN_NAME} detected, upgrading"
            install "${BIN_NAME}"
        else
            reportWarning "$(${BIN_NAME} --version) is already installed!"
        fi
    fi
}

function install() {
    local BIN_ARTIFACT
    BIN_ARTIFACT="${1}_.*_amd64.deb"
    cd /tmp || return 1
    aria2c "$(get_release_assets sharkdp/"${1}" | grep "${BIN_ARTIFACT}")" -o binary.deb
    sudo dpkg -i binary.deb
    rm -rf binary.deb 2>/dev/null
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install "${1:?}"

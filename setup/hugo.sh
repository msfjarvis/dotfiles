#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/hugo.deb 2>/dev/null' INT TERM EXIT

# shellcheck source=common
source "${SCRIPT_DIR:?}"/common
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install_hugo() {
    local HUGO HUGO_ARTIFACT LOCAL_HUGO_VERSION REMOTE_HUGO_VERSION
    HUGO="$(command -v hugo)"
    echoText "Checking and installing hugo"
    if [ -z "${HUGO}" ]; then
        install_hugo
    else
        LOCAL_HUGO_VERSION="$(hugo version | awk '{print $5}' | cut -d '-' -f 1)"
        REMOTE_HUGO_VERSION="$(get_latest_release gohugoio/hugo)"
        if [ "${LOCAL_HUGO_VERSION}" != "${REMOTE_HUGO_VERSION}" ]; then
            reportWarning "Outdated version of hugo detected, upgrading"
            install_hugo "${REMOTE_HUGO_VERSION}"
        else
            reportWarning "hugo $(hugo version | awk '{print $5}' | cut -d '-' -f 1) is already installed!"
        fi
    fi
}

function install_hugo() {
    local HUGO_ARTIFACT
    HUGO_ARTIFACT="hugo_extended_.*_Linux-64bit.deb"
    cd /tmp || return 1
    aria2c "$(get_release_assets gohugoio/hugo | grep "${HUGO_ARTIFACT}")" -o hugo.deb
    sudo dpkg -i hugo.deb
    rm -rf hugo.deb 2>/dev/null
    cd "${SCRIPT_DIR}" || return 1
}

check_and_install_hugo

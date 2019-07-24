#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}"/common
source "${SCRIPT_DIR}"/gitshit

function setup_gitconfig() {
    echoText "Setting up gitconfig"
    mv ~/.gitconfig ~/.gitconfig.old 2>/dev/null # Failsafe in case we screw up
    cp "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig
    for ITEM in $(fd -tf . "${SCRIPT_DIR}/gitconfig_fragments"); do
        DECRYPTED="${ITEM/.gpg/}"
        rm -f "${DECRYPTED}" 2>/dev/null
        gpg --decrypt "${ITEM}" > "${DECRYPTED}"
        [ ! -f "${DECRYPTED}" ] && break
        cat "${DECRYPTED}" >> ~/.gitconfig
        rm "${DECRYPTED}"
    done
}

setup_gitconfig

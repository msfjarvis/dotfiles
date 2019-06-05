#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}/common"

function setup_adb {
    local CLONE_DIR; CLONE_DIR=/tmp/adb-multi;
    if [ -d "${CLONE_DIR}" ]; then
        git -C "${CLONE_DIR}" pull origin master
    else
        git clone https://github.com/Kreach3r/adb-multi -b master "${CLONE_DIR}"
    fi
    echoText "Setting up multi-adb"
    cp "${SCRIPT_DIR}/config.cfg" "${CLONE_DIR}"/config.cfg
    "${CLONE_DIR}"/adb-multi generate "${HOME}/bin"
    cp "${CLONE_DIR}"/adb-multi ~/bin
    cp "${CLONE_DIR}"/config.cfg ~/bin
}

setup_adb

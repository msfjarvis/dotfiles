#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}/common"

function setup_adb {
    echoText "Setting up multi-adb"
    git -C "${SCRIPT_DIR}/adb-multi" reset --hard
    if [ -d "${SCRIPT_DIR}/patches/adb-multi" ]; then
        find "${SCRIPT_DIR}/patches/adb-multi/" -type f -exec git -C "${SCRIPT_DIR}"/adb-multi/ apply {} \;
    fi
    cp "${SCRIPT_DIR}/config.cfg" "${SCRIPT_DIR}"/adb-multi/config.cfg
    "${SCRIPT_DIR}"/adb-multi/adb-multi generate "${HOME}/bin"
    cp "${SCRIPT_DIR}"/adb-multi/adb-multi ~/bin
    git -C "${SCRIPT_DIR}/adb-multi" reset --hard
}

setup_adb

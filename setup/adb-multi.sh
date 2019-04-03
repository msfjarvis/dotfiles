#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}/common"

function setup_adb {
    echoText "Setting up multi-adb"
    cp "${SCRIPT_DIR}/config.cfg" "${SCRIPT_DIR}"/adb-multi/config.cfg
    "${SCRIPT_DIR}"/adb-multi/adb-multi generate "${HOME}/bin"
    cp "${SCRIPT_DIR}"/adb-multi/adb-multi ~/bin
}

setup_adb

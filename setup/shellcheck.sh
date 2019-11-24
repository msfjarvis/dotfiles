#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=common
source "${SCRIPT_DIR:?}"/common

function install_shellcheck() {
    echoText "Installing latest shellcheck"
    cd /tmp/ || return
    local SCVERSION
    SCVERSION="latest"
    wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-${SCVERSION?}.linux.x86_64.tar.xz" | tar -xJv
    sudo cp "shellcheck-${SCVERSION}/shellcheck" /usr/bin/
    rm -rf "shellcheck-${SCVERSION}"
    cd - || return
    shellcheck --version
}

install_shellcheck

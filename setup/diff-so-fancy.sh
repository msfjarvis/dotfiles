#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

source "${SCRIPT_DIR}"/common
source "${SCRIPT_DIR}"/gitshit

function install_dsf {
    echoText "Checking and installing 'diff-so-fancy'"
    if [ "$(command -v diff-so-fancy)" == "" ]; then
        echoText "Installing 'diff-so-fancy'"
        sudo aria2c 'https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy' --allow-overwrite=true -d /usr/local/bin -o diff-so-fancy
        sudo chmod +x /usr/local/bin/diff-so-fancy
    else
        INSTALLED_VERSION="$(grep "my \$VERSION = " /usr/local/bin/diff-so-fancy | cut -d \" -f 2)"
        LATEST_VERSION="$(get_latest_release so-fancy/diff-so-fancy | sed 's/v//')"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            echoText "Installing 'diff-so-fancy'"
            sudo aria2c 'https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy' --allow-overwrite=true -d /usr/local/bin -o diff-so-fancy
            sudo chmod +x /usr/local/bin/diff-so-fancy
        else
            reportWarning "'diff-so-fancy' ${INSTALLED_VERSION} is already installed!"
        fi
    fi
}

install_dsf

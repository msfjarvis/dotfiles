#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

function setup_android_udev {
    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
    source "${SCRIPT_DIR}"/../common
    echoText "Installing latest Android udev rules"
    curl "https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules" 2>/dev/null | sudo tee /etc/udev/rules.d/51-android.rules 1>/dev/null
    sudo chmod a+r /etc/udev/rules.d/51-android.rules
    sudo udevadm control --reload-rules
    sudo service udev restart
}

setup_android_udev

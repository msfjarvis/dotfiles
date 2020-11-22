#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh

function setup_android_udev() {
  echoText "Installing latest Android udev rules"
  sudo curl -s --create-dirs -L "https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules" -o /etc/udev/rules.d/51-android.rules
  sudo chmod a+r /etc/udev/rules.d/51-android.rules
  sudo udevadm control --reload-rules
  sudo service udev restart
}

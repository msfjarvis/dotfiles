#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh

SDK_TOOLS=commandlinetools-linux-6609375_latest.zip

function setup_android_sdk() {
  echoText "Installing Android SDK"
  mkdir -p "${HOME:?}"/Android/Sdk
  cd "${HOME}"/Android/Sdk || return 1
  if [ ! -f "${SDK_TOOLS}" ]; then
    aria2c https://dl.google.com/android/repository/"${SDK_TOOLS}"
  fi
  unzip -qo "${SDK_TOOLS}"
  while read -r package; do
    yes | ./tools/bin/sdkmanager --sdk_root="$(pwd)" "${package:?}"
  done <"${SCRIPT_DIR}"/setup/sdk-packages-android.txt
  rm "${SDK_TOOLS}"
  cd - || exit
}

setup_android_sdk

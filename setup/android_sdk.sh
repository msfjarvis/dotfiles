#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh

SDK_TOOLS=commandlinetools-linux-6609375_latest.zip

function setup_android_sdk() {
  SDK_DIR="${HOME:?}/Android/Sdk"
  echoText "Installing Android SDK"
  mkdir -p "${SDK_DIR}"
  if [ ! -f "${SDK_TOOLS}" ]; then
    wget https://dl.google.com/android/repository/"${SDK_TOOLS}" -O "${SDK_DIR}"/"${SDK_TOOLS}"
  fi
  unzip -qo "${SDK_DIR}"/"${SDK_TOOLS}" -d "${SDK_DIR}"
  while read -r package; do
    yes | "${SDK_DIR}"/tools/bin/sdkmanager --sdk_root="${HOME:?}/Android/Sdk/" "${package:?}"
  done <"${SCRIPT_DIR}"/setup/sdk-packages-android.txt
  rm "${SDK_TOOLS}"
  cd - || exit
}

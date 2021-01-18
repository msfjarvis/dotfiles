#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh

trap 'rm -rf /tmp/tools.zip 2>/dev/null' INT TERM EXIT

SDK_TOOLS=commandlinetools-linux-6858069_latest.zip

function setup_android_sdk() {
  SDK_DIR="${HOME:?}/Android/Sdk"
  echoText "Installing Android SDK"
  mkdir -p "${SDK_DIR}"
  if [ ! -f "${SDK_TOOLS}" ]; then
    wget https://dl.google.com/android/repository/"${SDK_TOOLS}" -O /tmp/tools.zip
  fi
  unzip -qo /tmp/tools.zip -d "${SDK_DIR}"
  while read -r package; do
    yes | "${SDK_DIR}"/tools/bin/sdkmanager "${package:?}"
  done <"${SCRIPT_DIR}"/setup/sdk-packages-android.txt
  rm /tmp/tools.zip
  cd - || exit
}

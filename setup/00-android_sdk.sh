#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh

trap 'rm -rf /tmp/tools.zip 2>/dev/null' INT TERM EXIT

SDK_TOOLS=commandlinetools-linux-7583922_latest.zip

function setup_android_sdk() {
  SDK_DIR="/mnt/mediahell/Android/Sdk"
  if [ ! -d "${SDK_DIR}" ]; then
    mkdir -p "${SDK_DIR}"
  fi
  echoText "Installing Android SDK"
  mkdir -p "${SDK_DIR}"
  if [ ! -f "${SDK_TOOLS}" ]; then
    wget https://dl.google.com/android/repository/"${SDK_TOOLS}" -O /tmp/tools.zip
  fi
  unzip -qo /tmp/tools.zip -d "${SDK_DIR}"
  while read -r package; do
    yes | "${SDK_DIR}"/cmdline-tools/bin/sdkmanager --sdk_root="${SDK_DIR}" "${package:?}"
  done <"${SCRIPT_DIR}"/setup/sdk-packages-android.txt
  rm /tmp/tools.zip
  cd - || exit
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  set -euo pipefail
  setup_android_sdk
  set +euo pipefail
fi

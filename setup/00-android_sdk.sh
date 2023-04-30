#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

# shellcheck source=common
source "${SCRIPT_DIR:?}"/common

trap 'rm -rf /tmp/tools.zip 2>/dev/null' INT TERM EXIT

SDK_TOOLS=commandlinetools-linux-7583922_latest.zip

function setup_android_sdk() {
  local SDK_DIR TMP_DIR
  SDK_DIR="${1:-$HOME/Android/Sdk}"
  TMP_DIR="$(mktemp -d)"
  if [ ! -d "${SDK_DIR}" ]; then
    mkdir -p "${SDK_DIR}"
  fi
  echoText "Installing Android SDK"
  if [ ! -f "${SDK_TOOLS}" ]; then
    wget https://dl.google.com/android/repository/"${SDK_TOOLS}" -O /tmp/tools.zip
  fi
  unzip -qo /tmp/tools.zip -d "${TMP_DIR}"
  mkdir -p "${SDK_DIR}"/cmdline-tools/latest/
  pushd "${TMP_DIR}/cmdline-tools/"
  cp -vR ./* "${SDK_DIR}"/cmdline-tools/latest/
  popd
  pushd "${SDK_DIR}"
  while read -r package; do
    yes | "${SDK_DIR}"/cmdline-tools/latest/bin/sdkmanager "${package:?}"
  done <"${SCRIPT_DIR}"/setup/sdk-packages-android.txt
  popd
  rm -rf /tmp/tools.zip "${TMP_DIR}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  set -euo pipefail
  setup_android_sdk "$@"
  set +euo pipefail
fi

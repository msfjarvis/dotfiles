#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap "rm /tmp/binary.deb 2>/dev/null" INT TERM EXIT

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install() {
  local BIN BIN_NAME INSTALLED_VERSION LATEST_VERSION
  BIN_NAME="${1}"
  BIN="$(command -v "${BIN_NAME:?}")"
  echoText "Checking and installing ${BIN_NAME}"
  if [ -z "${BIN}" ]; then
    install "${BIN_NAME}"
  else
    INSTALLED_VERSION="$(${BIN_NAME} --version | awk '{print $2}')"
    LATEST_VERSION="$(get_latest_release sharkdp/"${BIN_NAME}" | sed 's/v//')"
    if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
      printUpgradeBanner "${BIN_NAME}" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
      install "${BIN_NAME}"
    else
      printUpToDateBanner "${BIN_NAME}" "${INSTALLED_VERSION}"
    fi
  fi
}

function install() {
  local BIN_ARTIFACT
  BIN_ARTIFACT="${1}_.*_amd64.deb"
  cd /tmp || return 1
  aria2c "$(get_release_assets sharkdp/"${1}" | grep "${BIN_ARTIFACT}")" -o binary.deb
  sudo dpkg -i binary.deb
  rm -rf binary.deb 2>/dev/null
  cd "${SCRIPT_DIR}" || return 1
}

check_and_install "${1:?}"

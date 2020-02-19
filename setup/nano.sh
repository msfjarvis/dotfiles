#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm -rf /tmp/nano* 2>/dev/null' INT TERM EXIT

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh

function install_nano() {
  local INSTALLED_VERSION LATEST_VERSION
  echoText "Checking and updating nano"
  INSTALLED_VERSION="$(nano --version | head -n1 | awk '{print $4}')"
  LATEST_VERSION="4.8"
  if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
    printUpgradeBanner "nano" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
    sudo apt purge nano -y
    cd /tmp || return 1
    dl https://www.nano-editor.org/dist/v4/nano-"${LATEST_VERSION}".tar.xz nano.tar.xz
    tar xf nano.tar.xz
    cd nano-"${LATEST_VERSION}" || return 1
    CC=clang CXX=clang++ ./configure --enable-color --enable-extra --enable-multibuffer --enable-nanorc --enable-utf8 --disable-libmagic
    make all -j"$(nproc)"
    sudo make install
    cd "${SCRIPT_DIR}" || return 1
    rm -rf /tmp/nano.tar.xz /tmp/nano-"${LATEST_VERSION}" || return 1
  else
    printUpToDateBanner "nano" "${INSTALLED_VERSION}"
  fi
  rm -rf /tmp/nano 2>/dev/null
}

install_nano

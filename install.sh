#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export SCRIPT_DIR

# shellcheck source=common
source "${SCRIPT_DIR}"/common
# shellcheck source=system
source "${SCRIPT_DIR}"/system

trap 'exit 1' INT TERM

if [[ -n ${RUN_SETUP} ]]; then

  for i in "${SCRIPT_DIR}"/setup/*.sh; do
    name="$(basename "${i/.sh/}")"
    normalized_name="${name//[[:digit:]]/}"
    normalized_name="${normalized_name/-/}"
    # shellcheck disable=SC1090
    . "$i"
    setup_"$normalized_name"
    unset name setup_"$normalized_name"
  done
fi

cd "${SCRIPT_DIR}" || exit 1

echoText "Setting up gitconfig"
cp "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig
cp "${SCRIPT_DIR}/.global-gitignore" ~/.gitignore

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

declare -a SCRIPTS=("paste")

# Create binaries directory
mkdir -p ~/bin/

for i in "${SCRIPT_DIR}"/setup/*.sh; do
  name="$(basename "${i/.sh/}")"
  normalized_name="${name//[[:digit:]]/}"
  normalized_name="${normalized_name/-/}"
  # shellcheck disable=SC1090
  . "$i"
  setup_"$normalized_name"
  unset name setup_"$normalized_name"
done

cd "${SCRIPT_DIR}" || exit 1

echoText "Moving credentials"
gpg --decrypt "${SCRIPT_DIR}"/.secretcreds.gpg >~/.secretcreds

if [ -f ~/.bashrc ]; then
  ret="$(grep -qF "shell-init" ~/.bashrc)"
  if [ "${ret}" ]; then
    reportWarning "shell-init is not sourced in the bashrc, appending"
    echo "source ${SCRIPT_DIR}/shell-init" >>~/.bashrc
  fi
fi

echoText "Installing scripts"
for SCRIPT in "${SCRIPTS[@]}"; do
  echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
  rm -rf ~/bin/"${SCRIPT}"
  ln -s "${SCRIPT_DIR}"/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

echoText "Setting up gitconfig"
cp "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig
cp "${SCRIPT_DIR}/.global-gitignore" ~/.gitignore

#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export SCRIPT_DIR

# shellcheck source=common
source "${SCRIPT_DIR}"/common
# shellcheck source=system
source "${SCRIPT_DIR}"/system

trap 'exit 1' INT TERM

IS_NIX=true
if type apt &>/dev/null; then
  unset IS_NIX
fi
declare -a SCRIPTS=("build-kernel" "paste" "zpl")

# Create binaries directory
mkdir -p ~/bin/

# Install standard packages.
if [ -z "${IS_NIX}" ]; then
  echoText "Installing necessary packages"
  sudo apt install -y autoconf automake inkscape mosh wget
fi

if [ -z "${IS_NIX}" ]; then
  bash -i "${SCRIPT_DIR}"/setup/android-udev.sh
  bash -i "${SCRIPT_DIR}"/setup/xclip.sh
fi

cd "${SCRIPT_DIR}" || exit 1

echoText 'Installing nanorc'
cp -v "${SCRIPT_DIR}"/.nanorc ~/.nanorc
if [ ! -d "${HOME}/.nano" ]; then
  git clone https://github.com/scopatz/nanorc ~/.nano -b master
else
  git -C "${HOME}/.nano" pull --rebase
fi

# add all includes from ~/.nano/nanorc if they're not already there
while read -r inc; do
  if ! grep -q "$inc" ~/.nanorc; then
    echo "$inc" >>~/.nanorc
  fi
done <~/.nano/nanorc

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

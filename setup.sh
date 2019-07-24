#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}"/common
source "${SCRIPT_DIR}"/system

trap 'exit 1' SIGINT SIGTERM

declare -a SCRIPTS=("kronic-build" "build-caesium" "build-kernel" "build-twrp" "hastebin")

# Create binaries directory
mkdir -p ~/bin/

# Install standard packages.
echoText "Installing necessary packages"
sudo apt install -y aria2 autoconf automake axel cowsay curl jq libxmu-dev lolcat mosh shellcheck wget

# Update all submodules
git -C "${SCRIPT_DIR}" submodule update --init --recursive

source "${SCRIPT_DIR}"/setup/android-udev.sh
source "${SCRIPT_DIR}"/setup/bat.sh
source "${SCRIPT_DIR}"/setup/diff-so-fancy.sh
source "${SCRIPT_DIR}"/setup/fd.sh
source "${SCRIPT_DIR}"/setup/gdrive.sh
source "${SCRIPT_DIR}"/setup/gitconfig.sh
source "${SCRIPT_DIR}"/setup/hub.sh
source "${SCRIPT_DIR}"/setup/xclip.sh

cd "${SCRIPT_DIR}" || exit 1

echoText 'Installing nanorc'
cp -v "${SCRIPT_DIR}"/.nanorc ~/.nanorc

echoText "Moving credentials"
gpg --decrypt "${SCRIPT_DIR}"/.secretcreds.gpg > ~/.secretcreds

# SC2076: Don't quote rhs of =~, it'll match literally rather than as a regex.
# SC2088: Note that ~ does not expand in quotes.
# shellcheck disable=SC2076,SC2088
if [[ ! "${PATH}" =~ "~/bin" ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH="~/bin":$PATH' >> ~/.bashrc
fi

ret="$(grep -qF "source ${SCRIPT_DIR}/functions" ~/.bashrc)"
if [ "${ret}" ]; then
    reportWarning "functions is not sourced in the bashrc, appending"
    echo "source ${SCRIPT_DIR}/functions" >> ~/.bashrc
fi

echoText "Installing scripts"
for SCRIPT in "${SCRIPTS[@]}"; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    rm -rf ~/bin/"${SCRIPT}"
    ln -s "${SCRIPT_DIR}"/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

if [[ "$*" =~ --all ]] && [ "$(display_exists)" ]; then
    source "${SCRIPT_DIR}"/setup/adb-multi.sh
fi

#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# Source common functions
SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
source "${SCRIPT_DIR}"/common

declare -a SCRIPTS=("kronic-build" "build-caesium" "build-kernel" "build-twrp" "hastebin")
declare -a TDM_SCRIPTS=("gerrit-review")
declare -a GPG_KEYS=("public_old.asc" "private_old.asc")

# Create binaries directory
mkdir -p ~/bin/

# Install standard packages.
echoText "Installing necessary packages"
sudo apt install -y android-tools-adb jq curl wget axel mosh xclip aria2

# Update all submodules
git -C "${SCRIPT_DIR}" submodule update --init --recursive

source "${SCRIPT_DIR}"/setup/bat.sh
source "${SCRIPT_DIR}"/setup/diff-so-fancy.sh
source "${SCRIPT_DIR}"/setup/gdrive.sh
source "${SCRIPT_DIR}"/setup/hub.sh

echoText 'Installing nanorc'
cp -v "${SCRIPT_DIR}"/.nanorc ~/.nanorc

echoText "Importing GPG keys"
for KEY in "${GPG_KEYS[@]}"; do
    gpg --import "${SCRIPT_DIR}"/gpg_keys/"${KEY}"
done

echoText "Moving credentials"
gpg --decrypt "${SCRIPT_DIR}"/.secretcreds.gpg > ~/.secretcreds

# SC2076: Don't quote rhs of =~, it'll match literally rather than as a regex.
# SC2088: Note that ~ does not expand in quotes.
# shellcheck disable=SC2076,SC2088
if [[ ! "${PATH}" =~ "~/bin" ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH="~/bin":$PATH' >> ~/.bashrc
fi

ret="$(grep -q "source ${SCRIPT_DIR}/functions" ~/.bashrc)"
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

echoText "Setting up tdm-scripts"
for SCRIPT in "${TDM_SCRIPTS[@]}"; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    cp "${SCRIPT_DIR}"/tdm-scripts/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

echoText "Setting up gitconfig"
mv ~/.gitconfig ~/.gitconfig.old 2>/dev/null # Failsafe in case we screw up
cp "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig
# SC2044: For loops over find output are fragile. Use find -exec or a while read loop.
# Disabling until I have a better idea
# shellcheck disable=SC2044
for ITEM in $(find gitconfig_fragments -type f); do
    DECRYPTED="${ITEM/.gpg/}"
    rm -f "${DECRYPTED}" 2>/dev/null
    gpg --decrypt "${ITEM}" > "${DECRYPTED}"
    [ ! -f "${DECRYPTED}" ] && break
    cat "${DECRYPTED}" >> ~/.gitconfig
    rm "${DECRYPTED}"
done

if [[ "$*" =~ --setup-adb ]] || [[ "$*" =~ --all ]]; then
    echoText "Setting up multi-adb"
    "${SCRIPT_DIR}"/adb-multi/adb-multi generate
    cp "${SCRIPT_DIR}"/adb-multi/adb-multi ~/bin
fi

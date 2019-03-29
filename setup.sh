#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# Source common functions
CUR_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
source "${CUR_DIR}"/common

declare -a SCRIPTS=("kronic-build" "build-caesium" "build-kernel" "build-twrp" "hastebin")
declare -a GPG_KEYS=("public_old.asc" "private_old.asc" "public_prjkt.asc" "private_prjkt.asc")

# Create binaries directory
mkdir -p ~/bin/

# Install standard packages.
echoText "Installing necessary packages"
sudo apt install -y android-tools-adb aria2 autoconf automake axel cowsay curl jq libxmu-dev lolcat mosh shellcheck silversearcher-ag wget

# Update all submodules
git -C "${CUR_DIR}" submodule update --init --recursive

source "${CUR_DIR}"/setup/android-udev.sh
source "${CUR_DIR}"/setup/bat.sh
source "${CUR_DIR}"/setup/diff-so-fancy.sh
source "${CUR_DIR}"/setup/gdrive.sh
source "${CUR_DIR}"/setup/hub.sh
source "${CUR_DIR}"/setup/xclip.sh

cd "${CUR_DIR}" || exit 1

echoText 'Installing nanorc'
cp -v "${CUR_DIR}"/.nanorc ~/.nanorc

echoText "Importing GPG keys"
for KEY in "${GPG_KEYS[@]}"; do
    gpg --import "${CUR_DIR}"/gpg_keys/"${KEY}"
done

echoText "Moving credentials"
gpg --decrypt "${CUR_DIR}"/.secretcreds.gpg > ~/.secretcreds

# SC2076: Don't quote rhs of =~, it'll match literally rather than as a regex.
# SC2088: Note that ~ does not expand in quotes.
# shellcheck disable=SC2076,SC2088
if [[ ! "${PATH}" =~ "~/bin" ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH="~/bin":$PATH' >> ~/.bashrc
fi

ret="$(grep -qF "source ${CUR_DIR}/functions" ~/.bashrc)"
if [ "${ret}" ]; then
    reportWarning "functions is not sourced in the bashrc, appending"
    echo "source ${CUR_DIR}/functions" >> ~/.bashrc
fi

echoText "Installing scripts"
for SCRIPT in "${SCRIPTS[@]}"; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    rm -rf ~/bin/"${SCRIPT}"
    ln -s "${CUR_DIR}"/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

echoText "Setting up gitconfig"
mv ~/.gitconfig ~/.gitconfig.old 2>/dev/null # Failsafe in case we screw up
cp "${CUR_DIR}/.gitconfig" ~/.gitconfig
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

if [[ "$*" =~ --all ]] && [ "$(display_exists)" ]; then
    echoText "Setting up multi-adb"
    git -C "${CUR_DIR}/adb-multi" reset --hard
    find patches/adb-multi/ -type f -exec git -C "${CUR_DIR}"/adb-multi/ apply "${CUR_DIR}"/{} \;
    cp "${CUR_DIR}/config.cfg" "${CUR_DIR}"/adb-multi/config.cfg
    "${CUR_DIR}"/adb-multi/adb-multi generate "${HOME}/bin"
    cp "${CUR_DIR}"/adb-multi/adb-multi ~/bin
    git -C "${CUR_DIR}/adb-multi" reset --hard
fi

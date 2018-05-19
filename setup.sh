#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-only #

SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
source "${SCRIPT_DIR}"/common
git -C "${SCRIPT_DIR}" submodule update --init --recursive

declare -a SCRIPTS=("kronic-build" "build-caesium" "build-kernel" "build-twrp" "hastebin")
declare -a TDM_SCRIPTS=("gerrit-review")
declare -a GPG_KEYS=("public_prjkt.asc" "private_prjkt.asc")

mkdir -p ~/bin/

echoText "Checking and installing hub"
HUB="$(command -v hub)"
if [ "${HUB}" == "" ]; then
    HUB_ARCH=linux-amd64
    wget "$(curl -s https://api.github.com/repos/github/hub/releases/latest | jq -r ".assets[] | select(.name | test(\"${HUB_ARCH}\")) | .browser_download_url")" -O hub.tgz
    mkdir -p hub
    tar -xf hub.tgz -C hub
    sudo ./hub/*/install --prefix=/usr/local/
else
    reportWarning "$(hub --version) is already installed!"
fi

echoText "Installing scripts"
for SCRIPT in "${SCRIPTS[@]}"; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    rm -rf ~/bin/"${SCRIPT}"
    ln -s "${SCRIPT_DIR}"/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

echoText "Importing GPG keys"
for KEY in "${GPG_KEYS[@]}"; do
    gpg --import "${SCRIPT_DIR}"/gpg_keys/"${KEY}"
done

echoText "Moving credentials"
gpg "${SCRIPT_DIR}"/.secretcreds.gpg
[ -f "${SCRIPT_DIR}"/.secretcreds ] && mv "${SCRIPT_DIR}"/.secretcreds ~/.secretcreds
rm -f "${SCRIPT_DIR}"/.secretcreds 2>/dev/null

echoText "Setting up tdm-scripts"
for SCRIPT in "${TDM_SCRIPTS[@]}"; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    cp "${SCRIPT_DIR}"/tdm-scripts/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

if [[ ! "${PATH}" =~ ~/bin ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH=~/bin:$PATH' >> ~/.bashrc
fi

if [[ ! $(grep "source ${SCRIPT_DIR}/functions" ~/.bashrc) ]]; then
    reportWarning "functions is not sourced in the bashrc, appending"
    echo "source ${SCRIPT_DIR}/functions" >> ~/.bashrc
fi

if [[ "$@" =~ --install-gitconfig || "$@" =~ --all ]]; then
  echoText "Setting up gitconfig"
  mv ~/.gitconfig ~/.gitconfig.old 2>/dev/null # Failsafe in case we screw up
  cp "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig
  for ITEM in $(find gitconfig_fragments -type f); do
    DECRYPTED="${ITEM/.gpg/}"
    rm -f "${DECRYPTED}" 2>/dev/null
    gpg "${ITEM}"
    [[ ! -f "${DECRYPTED}" ]] && break
    cat "${DECRYPTED}" >> ~/.gitconfig
    rm "${DECRYPTED}"
  done
fi

if [[ "$@" =~ --setup-adb || "$@" =~ --all ]]; then
    echoText "Setting up multi-adb"
    "${SCRIPT_DIR}"/adb-multi/adb-multi generate
    cp "${SCRIPT_DIR}"/adb-multi/adb-multi ~/bin
fi
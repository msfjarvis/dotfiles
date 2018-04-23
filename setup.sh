#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-only #

SCRIPT_DIR="$(cd "$( dirname $( readlink -f "${BASH_SOURCE[0]}" ) )" && pwd)"
source ${SCRIPT_DIR}/common

declare -a SCRIPTS=("build-xos" "build-caesium" "build-kernel" "build-twrp" "hastebin")
declare -a TDM_SCRIPTS=("gerrit-review")

mkdir -p ~/bin/

echoText "Installing scripts"
for SCRIPT in ${SCRIPTS[@]}; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    rm -rf ~/bin/${SCRIPT}
    ln -s ${SCRIPT_DIR}/${SCRIPT} ~/bin/${SCRIPT}
done

echoText "Setting up tdm-scripts"
for SCRIPT in ${TDM_SCRIPTS[@]}; do
    echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
    cp ${SCRIPT_DIR}/tdm-scripts/${SCRIPT} ~/bin/${SCRIPT}
done

if [[ ! $(grep -q "msfjarvis-aliases-start" ~/.bash_aliases) || ! "$@" =~ "--all" ]]; then
    reportWarning "Bash aliases not installed, installing now"
    echo $'\n' >> ~/.bash_aliases
    cat ${SCRIPT_DIR}/.bash_aliases >> ~/.bash_aliases
fi

if [[ ! $(echo $PATH) =~ ~/bin ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH=~/bin:$PATH' >> ~/.bashrc
fi

if [[ ! grep -q "source ${SCRIPT_DIR}/functions" ~/.bashrc ]]; then
    reportWarning "functions is not sourced in the bashrc, appending"
    echo $'\n' >> ~/.bashrc # Never assume with people like me who don't leave newlines
    echo "source ${SCRIPT_DIR}/functions" >> ~/.bashrc
fi

if [[ "$@" =~ "--install-gitconfig" || "$@" =~ "--all" ]]; then
  echoText "Setting up gitconfig"
  mv ~/.gitconfig ~/.gitconfig.old # Failsafe in case we screw up
  cp ${SCRIPT_DIR}/.gitconfig ~/.gitconfig
  for item in $(find gitconfig_fragments -name fragment_*); do
    decrypted=$(echo ${item} | cut -d '.' -f 1)
    rm -f ${decrypted} 2>/dev/null
    gpg ${item}
    [[ ! -f ${decrypted} ]] && break
    cat ${decrypted} >> ~/.gitconfig
  done
fi

if [[ "$@" =~ "--setup-adb" || "$@" =~ "--all" ]]; then
    echoText "Setting up multi-adb"
    ${SCRIPT_DIR}/adb-multi/adb-multi generate
    cp ${SCRIPT_DIR}/adb-multi/adb-multi ~/bin
fi
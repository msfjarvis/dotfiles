#!/bin/bash

SCRIPT_DIR="$(cd "$( dirname $( readlink -f "${BASH_SOURCE[0]}" ) )" && pwd)"
source ${SCRIPT_DIR}/common

declare -a SCRIPTS=("build-xos" "build-caesium" "build-twrp" "hastebin")

mkdir -p ~/bin/

for SCRIPT in ${SCRIPTS[@]};do
    rm -rf ~/bin/${SCRIPT}
    ln -s ${SCRIPT_DIR}/${SCRIPT} ~/bin/${SCRIPT}
done

if [[ ! $(echo $PATH) =~ /home/$(whoami)/bin ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH=~/bin:$PATH' >> ~/.bashrc
fi

if ! grep -q "source ${SCRIPT_DIR}/functions" ~/.bashrc; then
    reportWarning "functions is not sourced in the bashrc, appending"
    echo $'\n' >> ~/.bashrc # Never assume with people like me who don't leave newlines
    echo "source ${SCRIPT_DIR}/functions" >> ~/.bashrc
fi
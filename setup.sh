#!/bin/bash

SCRIPT_DIR="$(cd "$( dirname $( readlink -f "${BASH_SOURCE[0]}" ) )" && pwd)"
source ${SCRIPT_DIR}/common

declare -a SCRIPTS=("build-xos" "build-caesium" "build-twrp")

mkdir -p ~/bin/

for SCRIPT in ${SCRIPTS[@]};do
    ln -s ${SCRIPT_DIR}/${SCRIPT} ~/bin/${SCRIPT}
done

if [[ ! $(echo $PATH) =~ /home/$(whoami)/bin ]]; then
    reportWarning "~/bin is not in PATH, appending the export to bashrc"
    echo $'\nexport PATH=~/bin:$PATH' >> ~/.bashrc
fi

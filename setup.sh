#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export SCRIPT_DIR
# shellcheck source=common
source "${SCRIPT_DIR}"/common
# shellcheck source=system
source "${SCRIPT_DIR}"/system

trap 'exit 1' INT TERM

declare -a SCRIPTS=("build-caesium" "build-kernel" "hastebin" "kronic-build")

# Create binaries directory
mkdir -p ~/bin/

# Install standard packages.
echoText "Installing necessary packages"
sudo apt install -y aria2 autoconf automake cowsay curl fortune-mod fortunes fortunes-off inkscape jq libxmu-dev libgdk-pixbuf2.0-dev libncursesw5-dev libxml2-utils lolcat mosh pidcat wget sassc

bash -i "${SCRIPT_DIR}"/setup/android-udev.sh
bash -i "${SCRIPT_DIR}"/setup/diff-so-fancy.sh
bash -i "${SCRIPT_DIR}"/setup/gdrive.sh
bash -i "${SCRIPT_DIR}"/setup/hub.sh
bash -i "${SCRIPT_DIR}"/setup/hugo.sh
bash -i "${SCRIPT_DIR}"/setup/nano.sh
bash -i "${SCRIPT_DIR}"/setup/ripgrep.sh
bash -i "${SCRIPT_DIR}"/setup/sharkdp.sh bat
bash -i "${SCRIPT_DIR}"/setup/sharkdp.sh diskus
bash -i "${SCRIPT_DIR}"/setup/sharkdp.sh fd
bash -i "${SCRIPT_DIR}"/setup/shellcheck.sh
bash -i "${SCRIPT_DIR}"/setup/shfmt.sh
bash -i "${SCRIPT_DIR}"/setup/xclip.sh

cd "${SCRIPT_DIR}" || exit 1

echoText 'Installing nanorc'
cp -v "${SCRIPT_DIR}"/.nanorc ~/.nanorc
if [ ! -d "${HOME}/.nano" ]; then
  git clone https://github.com/msfjarvis/nanorc ~/.nano -b master -o origin
  git -C "${HOME}/.nano" remote add upstream https://github.com/scopatz/nanorc
else
  git -C "${HOME}/.nano" remote update --prune
  git -C "${HOME}/.nano" branch --set-upstream-to=origin/master
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

# SC2076: Don't quote rhs of =~, it'll match literally rather than as a regex.
# SC2088: Note that ~ does not expand in quotes.
# shellcheck disable=SC2076,SC2088
if [[ ! ${PATH} =~ '~/bin' ]]; then
  reportWarning "~/bin is not in PATH, appending the export to bashrc"
  echo $'\nexport PATH="~/bin":$PATH' >>~/.bashrc
fi

ret="$(grep -qF "source ${SCRIPT_DIR}/functions" ~/.bashrc)"
if [ "${ret}" ]; then
  reportWarning "functions is not sourced in the bashrc, appending"
  echo "source ${SCRIPT_DIR}/functions" >>~/.bashrc
fi

echoText "Installing scripts"
for SCRIPT in "${SCRIPTS[@]}"; do
  echo -e "${CL_YLW}Processing ${SCRIPT}${CL_RST}"
  rm -rf ~/bin/"${SCRIPT}"
  ln -s "${SCRIPT_DIR}"/"${SCRIPT}" ~/bin/"${SCRIPT}"
done

echoText "Setting up gitconfig"
mv ~/.gitconfig ~/.gitconfig.old 2>/dev/null # Failsafe in case we screw up
cp "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig

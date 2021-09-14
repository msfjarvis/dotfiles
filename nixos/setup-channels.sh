#!/usr/bin/env bash

set -euxo pipefail

# Check if nix-channel is installed.
if command -v nix-channel; then

  # If channels exist already, remove all of them.
  if [ -f "${HOME}/.nix-channels" ]; then
    while read -r line; do
      channel_name="$(echo "$line" | cut -d ' ' -f 2)"
      nix-channel --remove "${channel_name}"
    done <"${HOME}/.nix-channels"
  fi

  # Add the nix channels we're interested in
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --add https://github.com/msfjarvis/nixpkgs/archive/8456f9bb2b029c7a67e53c61fb4730458b3b2225.tar.gz nixpkgs

  # Update channels
  nix-channel --update
fi

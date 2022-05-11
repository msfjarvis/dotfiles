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
  case "$(uname)" in
    "Linux")
      nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
      nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
      nix-channel --add https://github.com/oxalica/rust-overlay/archive/master.tar.gz rust-overlay
      ;;
    "Darwin")
      nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
      nix-channel --add https://nixos.org/channels/nixos-21.11 nixpkgs
      nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
      nix-channel --add https://github.com/oxalica/rust-overlay/archive/master.tar.gz rust-overlay
      ;;
  esac

  # Update channels
  nix-channel --update
fi

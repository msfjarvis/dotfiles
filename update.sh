#!/usr/bin/env bash

set -euxo pipefail

declare -a ALL_PACKAGES=(
  adb-sync
  adbear
  adbtuifm
  adx
  age-keygen-deterministic
  boop-gtk
  caddy-tailscale
  clipboard-substitutor
  cyberdrop-dl
  ficsit-cli
  gallery-dl-unstable
  gdrive
  gitice
  gitout
  glance
  gphotos-cdp
  hcctl
  healthchecks-monitor
  katbin
  linkleaner
  patreon-dl
  phanpy
  pidcat
  piv-agent
  prometheus-qbittorrent-exporter
  rucksack
  spot-unstable
  toml-cli
)

declare -r -A EXTRA_PARAMS=(
  ["caddy-tailscale"]="--version=branch"
  ["cyberdrop-dl"]="--version=branch"
  ["gallery-dl-unstable"]="--version=branch"
  ["glance"]="--version=branch=release/v0.7.0"
  ["hcctl"]="--version-regex=hcctl-v(.*)"
  ["healthchecks-monitor"]="--version-regex=healthchecks-monitor-v(.*)"
  ["phanpy"]="--url=https://github.com/cheeaun/phanpy"
  ["spot-unstable"]="--version=branch=development"
)

PKG="${1-}"
VERSION="${2-}"
NO_BUILD="${NO_BUILD-}"
CACHE_CMD="${CACHE_CMD-}"
declare -a PACKAGES_TO_BUILD=()
declare -a BASE_PARAMS=("--commit")
if [ -z "${NO_BUILD}" ]; then
  BASE_PARAMS+=("--build")
fi

if [ -z "${PKG}" ]; then
  PACKAGES_TO_BUILD+=("${ALL_PACKAGES[@]}")
else
  PACKAGES_TO_BUILD+=("${PKG}")
fi

for PACKAGE in "${PACKAGES_TO_BUILD[@]}"; do
  declare -a PARAMS=("${BASE_PARAMS[@]}")
  PPARAMS="${EXTRA_PARAMS["${PACKAGE}"]:-}"
  if [[ -n ${PPARAMS} ]]; then
    PARAMS+=("${PPARAMS}")
  fi
  if [ -n "${VERSION}" ]; then
    PARAMS+=("--version")
    PARAMS+=("${VERSION}")
  fi
  PARAMS+=("${PACKAGE}")
  nix-update "${PARAMS[@]}"
  if [ -n "${CACHE_CMD}" ]; then
    ${CACHE_CMD} ./result
  fi
done

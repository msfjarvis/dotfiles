#!/usr/bin/env bash

set -euxo pipefail

declare -a ALL_PACKAGES=(
  adbear
  adx
  clipboard-substitutor
  cyberdrop-dl
  gallery-dl-unstable
  gdrive
  glance
  gphotos-cdp
  katbin
  linkleaner
  # No idea why this doesn't like the update script
  # markfmt
  patreon-dl
  phanpy
  # Doesn't need updates
  # pidcat
  prometheus-qbittorrent-exporter
  rucksack
)

declare -r -A EXTRA_PARAMS=(
  ["cyberdrop-dl"]="--version=branch"
  ["forge"]="--version=branch"
  ["gallery-dl-unstable"]="--version=branch"
  ["glance"]="--version=branch=main"
  ["phanpy"]="--url=https://github.com/cheeaun/phanpy --version=branch"
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
    IFS=' ' read -ra SPLIT_PARAMS <<<"${PPARAMS}"
    for P in "${SPLIT_PARAMS[@]}"; do
      PARAMS+=("${P}")
    done
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

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
  # cyberdrop-dl
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
  pidcat
  piv-agent
  prometheus-qbittorrent-exporter
  rucksack
  spot-unstable
  toml-cli
  when
)

declare -A VERSION_REGEX=(
  ["hcctl"]="hcctl-v(.*)"
  ["healthchecks-monitor"]="healthchecks-monitor-v(.*)"
)

declare -A VERSION_OVERRIDE=(
  ["caddy-tailscale"]=1
  ["cyberdrop-dl"]=1
  ["gallery-dl-unstable"]=1
  ["glance"]="release/v0.7.0"
  ["spot-unstable"]="development"
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
  if [[ -v VERSION_REGEX["${PACKAGE}"] ]]; then
    PARAMS+=("--version-regex")
    PARAMS+=("${VERSION_REGEX["${PACKAGE}"]}")
  fi
  if [[ -v VERSION_OVERRIDE["${PACKAGE}"] ]]; then
    OVERRIDE="${VERSION_OVERRIDE["${PACKAGE}"]}"
    if [[ ${OVERRIDE} == "1" ]]; then
      PARAMS+=("--version=branch")
    else
      PARAMS+=("--version=branch=${OVERRIDE}")
    fi
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

#!/usr/bin/env bash

set -euxo pipefail

declare -a ALL_PACKAGES=(
  adb-sync
  adbtuifm
  adx
  boop-gtk
  clipboard-substitutor
  gdrive
  gitice
  gitout
  glance
  gphotos-cdp
  hcctl
  healthchecks-monitor
  katbin
  linkleaner
  monocraft-nerdfonts
  patreon-dl
  pidcat
  piv-agent
  prometheus-qbittorrent-exporter
  rnnoise-plugin-slim
  rucksack
  toml-cli
  when
)

declare -A VERSION_REGEX=(
  ["hcctl"]="hcctl-v(.*)"
  ["healthchecks-monitor"]="healthchecks-monitor-v(.*)"
)

declare -A UNSTABLE_PACKAGES=(
  ["caddy-tailscale"]=1
  ["prometheus-qbittorrent-exporter"]=1
)

PKG="${1-}"
VERSION="${2-}"
NO_BUILD="${NO_BUILD-}"
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
  if [[ -v UNSTABLE_PACKAGES["${PACKAGE}"] ]]; then
    PARAMS+=("--version=branch")
  fi
  if [ -n "${VERSION}" ]; then
    PARAMS+=("--version")
    PARAMS+=("${VERSION}")
  fi
  PARAMS+=("${PACKAGE}")
  nix-update "${PARAMS[@]}"
done

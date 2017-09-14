#!/bin/bash

# Colors
BOLD="\033[1m"
RED="\033[01;31m"
RST="\033[0m"
YLW="\033[01;33m"

# Prints a formatted header to let the user know what's being done
function echoText() {
    echo -e ${RED}
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e "==  ${1}  =="
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e ${RST}
}

# Prints an error in bold red
function reportError() {
    echo -e ""
    echo -e ${RED}"${1}"${RST}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
}

# Prints a warning in bold yellow
function reportWarning() {
    echo -e ""
    echo -e ${YLW}"${1}"${RST}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
}


# Checks if the script is being run from the top of the
# Android source tree
function isTop {
    [[ -d .repo/manifests/ ]] && echo 0 || echo 255
}

# Get the current TWRP version. Slightly hacky but works
function getCurrentVer {
    if [[ $(isTop) == 0 ]]; then
        echo $(grep TW_MAIN_VERSION_STR bootable/recovery/variables.h | grep -v TW_DEVICE_VERSION | awk '{print $3}' | sed 's/"//g')
    else
        echo ""
    fi
}

# Stub to work around issues with issuing multiple commands in
# oneline if blocks
function reportError {
    echo $@
    exit 1
}

# Set final TWRP version
function setVars {
    if [[ $(getCurrentVer) == "" ]]; then
        reportError "Are you sure you're building TWRP?"
    else
        [[ $tw_version == "" ]] && tw_real_ver=$(getCurrentVer) || tw_real_ver=$(getCurrentVer)-$tw_version
    fi
}

# Move teh files
function setupFiles {
    if [ -f out/target/product/$device/recovery.tar ]; then
        mv out/target/product/$device/recovery.tar twrp-$tw_real_ver-$device.tar
    else
        mv out/target/product/$device/recovery.img twrp-$tw_real_ver-$device.img
    fi
}

# Do the real build
function build {
    if [[ $(isTop) == 0 ]]; then
        setVars
        [[ $tw_version ]] && export TW_DEVICE_VERSION=$tw_version && echo "Setting version to $tw_real_ver"
        . build/envsetup.sh
        [[ $device ]] && lunch omni_$device-eng || reportError "No device specified"
        mka recoveryimage
        [[ $? == 0 ]] && setupFiles || reportError "Compilation failed"
    else
        echo "Script not run from top of source tree, aborting"
    fi
}

device=$1
tw_version=$2
build

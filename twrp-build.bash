#!/bin/bash

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
    mv out/target/product/$device/recovery.img twrp-$tw_real_ver-$device.img
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

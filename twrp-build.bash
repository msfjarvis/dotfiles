#!/bin/bash

# Colors
BOLD="\033[1m"
RED="\033[01;31m"
RST="\033[0m"
YLW="\033[01;33m"

# Prints a formatted header to let the user know what's being done
function echoText {
    echo -e ${RED}
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e "==  ${1}  =="
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e ${RST}
}

# Prints an error in bold red
function reportError {
    echo -e ""
    echo -e ${RED}"${1}"${RST}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
    exit 1
}

# Prints a warning in bold yellow
function reportWarning {
    echo -e ""
    echo -e ${YLW}"${1}"${RST}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
}


# Checks if the script is being run from the top of the
# Android source tree
function isTop {
    [[ -d .repo/manifests/ ]] || reportError "Not building inside an AOSP tree"
}

# Get the current TWRP version. Slightly hacky but works
function getCurrentVer {
    if [[ $(grep -Fx TW_MAIN_VERSION_STR bootable/recovery/variables.h) ]]; then
        echo $(grep -Fx TW_MAIN_VERSION_STR bootable/recovery/variables.h | grep -v TW_DEVICE_VERSION | awk '{print $3}' | sed 's/"//g')
    else
        echo ""
    fi
}

# Set final TWRP version
function setVars {
    unset TW_DEVICE_VERSION
    if [[ $(getCurrentVer) == "" ]]; then
        reportError "Are you sure you're building TWRP?"
    else
        [[ ${tw_version} == "" ]] && tw_real_ver=$(getCurrentVer) || tw_real_ver=$(getCurrentVer)-${tw_version}
    fi
    export TW_DEVICE_VERSION=${tw_version} && echoText "Setting version to ${tw_real_ver}"

}

function checkDevice {
    [[ $(find device -name vendorsetup.sh | cut -d / -f 3) == ${device} ]] || reportError "No sources for device \"${device}\" could be found"
}

# Move teh files
function setupFiles {
    if [ -f out/target/product/${device}/recovery.tar ]; then
        mv out/target/product/${device}/recovery.tar twrp-${tw_real_ver}-${device}.tar
    elif [ -f out/target/product/${device}/recovery.img ]; then
        mv out/target/product/${device}/recovery.img twrp-${tw_real_ver}-${device}.img
    else
        reportError "Compilation failed!"
    fi
}

# Do the real build
function build {
    isTop
    checkDevice
    echoText "Starting compilation"
    setVars
    . build/envsetup.sh
    lunch omni_${device}-eng
    mka clean
    mka recoveryimage
    setupFiles
}

device=$1
tw_version=$2
build

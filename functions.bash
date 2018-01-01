#!/usr/bin/env bash

export CCACHE_DIR=~/.ccache/
export GERRIT_USER=MSF-Jarvis
export ANDROID_PLATFORM_ROOT="/home/msfjarvis/xossrc"
export JARVISBOX_URL="https://jarvisbox.duckdns.org/caesium"
CL_BOLD="\033[1m"
CL_INV="\033[7m"
CL_RED="\033[01;31m"
CL_RST="\033[0m"
CL_YLW="\033[01;33m"
CL_BLUE="\033[01;34m"

function echoText {
    echo -e ${CL_RED}
    echo -e ${CL_BOLD}
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e "==  ${1}  =="
    echo -e "====$( for i in $( seq ${#1} ); do echo -e "=\c"; done )===="
    echo -e ${CL_RST}
}

function reportWarning {
    echo -e ""
    echo -e ${CL_YLW}"${1}"${CL_RST}
    if [[ -z ${2} ]]; then
        echo -e ""
    fi
}

function cpuinfo {
    grep -E '^model name|^cpu MHz' /proc/cpuinfo
}

function getAllCPUFreq {
    for i in {0..3};do cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor;done
}

function _setAllCPUFreq {
    for i in {0..3};do  echo ${1} > /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor;done
}

function _overclockAllCPUFreq {
    for i in {0..3};do echo $(cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_max_freq) > /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_min_freq;done
}

function overclockAllCPUFreq {
    exesudo _overclockAllCPUFreq ${@}
}

function setAllCPUFreq {
    exesudo _setAllCPUFreq ${@}
}

function createXos {
  PROJECT=$(pwd -P | sed -e "s#$ANDROID_PLATFORM_ROOT\/##; s#-caf.*##; s#\/default##")
  ssh ${GERRIT_USER}@review.halogenos.org -p 29418 gerrit create-project -p All-Projects -t REBASE_IF_NECESSARY android_$(echo $PROJECT | sed "s#$ANDROID_PLATFORM_ROOT/##" | sed "s#/#_#g#")
  git create halogenOS/android_$(echo $PROJECT | sed "s#$ANDROID_PLATFORM_ROOT/##" | sed "s#/#_#g#")
}

function xg {
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    PROJECT=$(pwd -P | sed -e "s#$ANDROID_PLATFORM_ROOT\/##; s#-caf.*##; s#\/default##")
    git remote remove gerrit 2>/dev/null
    git remote add gerrit ssh://$GERRIT_USER@review.halogenos.org:29418/android_$(echo $PROJECT | sed "s#$ANDROID_PLATFORM_ROOT/##" | sed "s#/#_#g#")
}

function gz {
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    PROJECT=$(pwd -P | sed -e "s#$ANDROID_PLATFORM_ROOT\/##; s#-caf.*##; s#\/default##")
    if (echo $PROJECT | grep -qv "^device")
    then
        PFX="GZOSP/"
    fi
    git remote remove gzgerrit 2>/dev/null
    git remote add gzgerrit ssh://$GERRIT_USER@review.gzospgzr.com:29418/$PFX$(echo $PROJECT | sed "s#$ANDROID_PLATFORM_ROOT/##" | sed "s#/#_#g#")
}

function gpush {
  echo ${GERRIT_PASSWD}
  BRANCH="XOS-8.1"
  if [ "$1" ]; then
  git push gerrit HEAD:refs/for/"${BRANCH}"/"$1"
  else
  git push gerrit HEAD:refs/for/"${BRANCH}"
  fi
}

function gzpush {
  BRANCH="8.0"
  if [ "$1" ]; then
  git push gzgerrit HEAD:refs/for/"${BRANCH}"/"$1"
  else
  git push gzgerrit HEAD:refs/for/"${BRANCH}"
  fi
}

function gfpush {
  echo ${GERRIT_PASSWD}
  BRANCH="${1}"
  [[ "${BRANCH}" == "" ]] && BRANCH="XOS-8.1"
  git push gerrit HEAD:refs/heads/"${BRANCH}"
}

function gffpush {
  echo ${GERRIT_PASSWD}
  BRANCH="${1}"
  [[ "${BRANCH}" == "" ]] && BRANCH="XOS-8.1"
  git push --force gerrit HEAD:refs/heads/"${BRANCH}"
}

# Utility functions
function transfer {
  if [ $# -eq 0 ]
    then echo "No arguments specified. Usage:
    echo transfer /tmp/test.md
    cat /tmp/test.md | transfer test.md"
    return 1
  fi
  tmpfile=$( mktemp -t transferXXX )
  if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
  curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
  else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile
  fi; cat $tmpfile
  rm -f $tmpfile
  echo ""
}

function makeapk {
    params=("$@")
    [[ -f "build.gradle" ]] || echo -e "${CL_RED} No build.gradle present, dimwit ${CL_RST}" || return 1
    local gradlecommand=""
    local buildtype=""
    case "${params[0]}" in
         "Debug"|"debug")
             gradlecommand="assembleDebug"
             buildtype="Debug"
             ;;
         "Release"|"release")
             gradlecommand="assembleRelease"
             buildtype="Release"
             ;;
    esac
    [[ "${buildtype}" == "" || "${gradlecommand}" == "" ]] && echo -e "${CL_RED} No build type specified ${CL_RST}" && return 1
    [[ "${params[1]}" == "install" ]] && gradlecommand="install${buildtype}"
    rm -rfv app/build/outputs/apk/"${buildtype,,}"/*
    #bash gradlew clean
    bash gradlew "${gradlecommand}"
}


# Server tooling
function startserver {
  gcloud compute instances start --project "heroic-diode-189916" --zone "us-west1-c" "jarvisbox"
}

function stopserver {
  gcloud compute instances stop --project "heroic-diode-189916" --zone "us-west1-c" "jarvisbox"
}

function serverconnect {
  gcloud compute --project "heroic-diode-189916" ssh --zone "us-west1-c" "jarvisbox"
}


# Telegram stuff
function tg {
    chat_id="${2}"
    [[ "${2}" == "" ]] && chat_id="${MSF_TG_ID}"
    curl -F chat_id="${chat_id}" -F document="@${1}" "https://api.telegram.org/bot${TG_BOT_ID}/sendDocument" 1>/dev/null 2>/dev/null
}

function tgm {
    chat_id="${2}"
    [[ "${2}" == "" ]] && chat_id="${MSF_TG_ID}"
    curl -F chat_id="${chat_id}" -F parse_mode="markdown" -F text="${1}" "https://api.telegram.org/bot${TG_BOT_ID}/sendMessage" 1>/dev/null 2>/dev/null
}

function ttg {
    file=$(transfer "${1}")
    tgm "[${1}](${file})"
}

function publish {
    rsync -avR ${1} root@jarvisbox.duckdns.org:/var/www/${2}/ --progress --verbose
}

function backup {
    for folder in $(adb shell find /sdcard/ -type d -maxdepth 1);do
        adb-sync --delete --reverse ${folder} ~/git-repos/backups/
    done
}

function pushcaesiumtg {
    file=${1}
    type=${2}
    case ${type} in
        "alpha"|"beta"|"stable") ;;
        *) echo "Invalid build type" && return ;;
    esac
    changelog_file=$(echo ${file} | sed 's/\.zip//')_changelog.txt
    git shortlog msf/XOS-8.0..HEAD > ${changelog_file}
    rsync ${changelog_file} root@jarvisbox.duckdns.org:/var/www/caesium/${type} --progress --verbose
    rsync zips/${file} root@jarvisbox.duckdns.org:/var/www/caesium/${type} --progress --verbose
    tgm "New [${type}](${JARVISBOX_URL}/${type}) build uploaded : [${file}](${JARVISBOX_URL}/${type}/${file})" "${OP3_CAESIUM_CHAT_ID}"
    tgm "New [${type}](${JARVISBOX_URL}/${type}) build uploaded : [${file}](${JARVISBOX_URL}/${type}/${file})" "${OP3_JAGRAV_CHAT_ID}"
}

function pushthemetg {
    tg "${1}" "${THEME_TESTERS_CHAT_ID}"
    tgm "${2}" "${THEME_TESTERS_CHAT_ID}"
}

# Random utility tooling
function myeyes {
  xflux -l 28.6869 -g 77.3525 -r 1 -k 2000
}

function findapks {
  find $1 -name "*.apk"
}

function weather {
    if (( `tput cols` < 125 )); then # 125 is min size for correct display
        [ -z "$1" ] && curl "wttr.in/Ghaziabad?0" || curl "wttr.in/~$1?0"
    else
        [ -z "$1" ] && curl "wttr.in/Ghaziabad" || curl "wttr.in/~$1"
    fi
}

function reboot {
  echo "Do you really wanna reboot??"
  read confirmation
  case "${confirmation}" in
      'y'|'Y')
          $(which reboot)
          ;;
      *)
          ;;
  esac
}

# Android + kernel stuff
function p2d {
  adb shell mount system
  final_path=$(adb shell find /system -name $1)
  echo "${final_path}"
  adb push $1 "${final_path}"
  adb shell umount system
}

function pushcaesium {
  adb push zips/$1 /sdcard/Caesium/
  adb shell twrp install /sdcard/Caesium/$1
}

function apply_patches {
    for patch in $(cat ~/git-repos/halogenOS/stable-queue/queue-3.18/series);do git am ~/git-repos/halogenOS/stable-queue/queue-3.18/${patch};done
}

function kgrep {
    find . -name .git -prune -o -path ./out -prune -o -regextype posix-egrep \
        -iregex '(.*\/Makefile|.*\/Kconfig|.*\/oneplus3_defconfig|.*\/caesium_defconfig)' -type f \
        -exec grep --color -n "$@" {} +
}

function flasherThingy {
    cd ~/Downloads/walleye
    for file in $(adb shell ls /sdcard/Download/Flash-Walleye-${1}-*.img);do
        partition=$(echo ${file} | cut -d '-' -f 5 | sed 's/\.img//')
        reportWarning "Pulling ${file}"
        if [ ${partition} == "boot" ];then
            adb pull /sdcard/MagiskManager/patched_boot.img $(basename ${file})
        else
            adb pull /sdcard/Download/$(basename ${file})
        fi
    done
    read -n 1 -s -r -p "Press any key to continue..."
    reportWarning "Rebooting to bootloader"
    adb reboot bootloader
    sleep 5
    for file in $(ls Flash-Walleye-${1}-*.img);do
        partition=$(echo ${file} | cut -d '-' -f 5 | sed 's/\.img//')
        fastboot flash ${partition} ${file}
    done
    echoText "Flashing complete, rebooting"
    fastboot reboot
}


function andromeda {
    bash ~/git-repos/andromeda_startup_scripts/Linux/start_andromeda.sh
}

function findJ {
    ag -ia ${1} | grep java | cut -f 1 -d ':' | uniq
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# EXESUDO
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#
# Purpose:
# -------------------------------------------------------------------- #
# Execute a function with sudo
#
# Params:
# -------------------------------------------------------------------- #
# $1:   string: name of the function to be executed with sudo
#
# Usage:
# -------------------------------------------------------------------- #
# exesudo "funcname" followed by any param
#
# -------------------------------------------------------------------- #
# Created 01 September 2012              Last Modified 02 September 2012

function exesudo ()
{
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    #
    # LOCAL VARIABLES:
    #
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

    #
    # I use underscores to remember it's been passed
    local _funcname_="$1"

    local params=( "$@" )               ## array containing all params passed here
    local tmpfile="/dev/shm/$RANDOM"    ## temporary file
    local filecontent                   ## content of the temporary file
    local regex                         ## regular expression
    local func                          ## function source


    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    #
    # MAIN CODE:
    #
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

    #
    # WORKING ON PARAMS:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #
    # Shift the first param (which is the name of the function)
    unset params[0]              ## remove first element
    # params=( "${params[@]}" )     ## repack array


    #
    # WORKING ON THE TEMPORARY FILE:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    content="#!/bin/bash\n\n"

    #
    # Write the params array
    content="${content}params=(\n"

    regex="\s+"
    for param in "${params[@]}"
    do
        if [[ "$param" =~ $regex ]]
            then
                content="${content}\t\"${param}\"\n"
            else
                content="${content}\t${param}\n"
        fi
    done

    content="$content)\n"
    echo -e "$content" > "$tmpfile"

    #
    # Append the function source
    echo "#$( type "$_funcname_" )" >> "$tmpfile"

    #
    # Append the call to the function
    echo -e "\n$_funcname_ \"\${params[@]}\"\n" >> "$tmpfile"


    #
    # DONE: EXECUTE THE TEMPORARY FILE WITH SUDO
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sudo bash "$tmpfile"
    rm "$tmpfile"
}
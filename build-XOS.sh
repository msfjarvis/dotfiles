#!/bin/bash

RED="\033[01;31m"
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache/${TARGET_DEVICE}/
export HOST_PREFERS_OWN_CCACHE=true

function reportError() {
    echo -e ""
    echo -e ${RED}"${1}"${RST}
    if [[ -z ${2} ]]; then
        exit 1
    else
        exit ${2}
    fi
}

function sendmessage {
  tgmessage=${1}
  BOT_ID=$(readConfig bot_id)
  CHAT_ID=$(readConfig chat_id)
  curl "https://api.telegram.org/bot$BOT_ID/sendmessage" --data "text=${tgmessage}&chat_id=${CHAT_ID}&parse_mode=Markdown"
}

function build {
  . build/envsetup.sh
  pickAndReset
  ccache -M 30G
  ./prebuilts/sdk/tools/jack-admin kill-server
  sendmessage "Build started."
  [ ${CLEAN} == "true" ] && make clean
  breakfast ${TARGET_DEVICE}
  build full XOS_${TARGET_DEVICE}-userdebug noclean
  ./prebuilts/sdk/tools/jack-admin kill-server
  cd $OUT
  [ -f ${XOS_VERSION}.zip ] && upload || sendmessage "Build failed." && return 1
}

function upload {
  cd ${OUT}
  filename=${XOS_VERSION}.zip
  ZIP_SIZE_MB=$(du -h ${filename} | awk '{print $1}' | sed s/M//)
  sendmessage "Uploading the zip ${filename}"
  sendmessage "zip size ${ZIP_SIZE_MB} MB"
  upload_duration=$(bc <<< '${ZIP_SIZE_MB}/8') # assuming 8mBps as a consistent upload speed
  sendmessage "Estimated upload duration: ${upload_duration} minutes"
  rsync -e ssh "$filename" msf-jarvis@frs.sourceforge.net:/home/frs/project/halogenos-builds/test_builds/${TARGET_DEVICE}
  ret=${?}
  build_url="https://sourceforge.net/projects/halogenos-builds/files/${TARGET_DEVICE}/${XOS_VERSION}.zip"
  [ ${ret} == 0 ] && sendmessage "[${XOS_VERSION}.zip]($build_url) uploaded" || sendmessage "Uploading failed"
  return ${?}
}

function init-if-needed {
  [ -d .repo/ ] || repo init -u git://github.com/halogenOS/android_manifest -b XOS-7.1
  repo sync -c --no-tags -f build
}

function pickAndReset {
  [ ${RESET} == "true" ] && reporeset 2>/dev/null
  temp=$(echo ${REPOPICK_TASKS} | sed s/\n//)
  if [ ${TEMP} != "" ]; then
    for task in ${repopick_tasks}; do
      repopick ${task}
    done
  fi
}

function notify {
  sendmessage "Building for device : ${TARGET_DEVICE}"
  sleep 0.5
  [ ${CLEAN} == "true" ] && sendmessage "Building clean" || sendmessage "Not building clean"
  sleep 0.5
  temp=$(echo ${REPOPICK_TASKS} | sed s/\n//)
  [ ${TEMP} != "" ] && sendmessage "repopick tasks : ${REPOPICK_TASKS}" || sendmessage "No repopicks"
}

function testBash {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "\033[01;31m"
    echo "Script HAS to be sourced, please DO NOT run it with the bash command!"
    echo -e "\033[0m"
    exit 255
  fi
}

function readConfig {
  CONFIG_FILE="~/.build_xos.config"
  [ -f ${CONFIG_FILE} ] || error "Missing config"
  echo $(grep $1  | cut -d = -f 2)
}

function loadInfo {
  while getopts ":ct:r:" opt; do
    case $opt in
      c)
        export CLEAN=true
        ;;
      t)
        TARGET_DEVICE=${OPTARG}
        ;;
      r)
        REPOPICK_TASKS=${OPTARG}
        ;;
      \?)
        echo "Invalid option: -${OPTARG}" >&2
        ;;
    esac
  done
}

testBash
mkdir -p ~/xos
cd ~/xos
loadInfo
init-if-needed
notify
build

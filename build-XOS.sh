#!/bin/bash

function sanitychecks() {
  test "$(echo $DEVICE)" != '' && (echo No device argument supplied; exit 1)
}

function calcvars() {
  lunchstring="XOS_$DEVICE-userdebug"
  file_name="XOS_$DEVICE_7.0_$(date +%Y%m%d).zip"
}
function init() {
  if [ ! -e ".repo/" ]; then
    repo init -u https://github.com/halogenOS/android_manifest -b XOS-7.0
  fi
  builddidexist=1
  if [ ! -e "build/" ]; then
    builddidexist=0
    repo sync build -c --no-tags
  fi
}
function build() {
  cd $PWD
  . build/envsetup.sh
  reposync
  build full $lunchstring
  test "$(ls $OUT/$file_name)" != '' && (echo Output ZIP not found; exit 3)
}

sanitychecks
calcvars
init
build

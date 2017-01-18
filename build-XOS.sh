function sendmessage() {
  tgmessage="$1"
  BOTID="$BOT_TOKEN"
  [ "$2" == "testers" ] && chat_id="$CHAT_ID" || chat_id=$2

  [ "$2" == "updates" ] && echo "Gonna get some updates for ya"
  if [ -z $chat_id ]; then
  echo
  echo "I didn't get a chat_id from your input, or you were confused,"
  echo "so here's a curl of /getUpdates for you to look at!"
  echo
  curl "https://api.telegram.org/bot$BOTID/getUpdates"
  else
  curl "https://api.telegram.org/bot$BOTID/sendmessage" --data "text=$tgmessage&chat_id=$chat_id&parse_mode=Markdown" &>/dev/null
  fi
}

function build() {
  . build/envsetup.sh
  [ "$SYNC" == "true" ] && rm -rf kernel/ && reposync turbo
  [ "$reset" != "false" ] && reporeset 2>/dev/null
  [ "$repopicks" != "none" ] && repopick "$repopicks"
  [ "$repopick_topic" != "none" ] && repopick -t "$repopick_topic"
  prebuilts/misc/linux-x86/ccache/ccache -M 30G
  ./prebuilts/sdk/tools/jack-admin kill-server
  sendmessage "Build started. This should take about 10 minutes!
  Changelog will come with the build link" "testers"
  [ "$CLEAN_BUILD" == "true" ] && make clean
  [ "$Release" == "true" ] && export TARGET_FORCE_DEXPREOPT=true && sendmessage "This is a release build" "testers" || sendmessage "This is a test build" "testers"
  breakfast $TARGET_DEVICE
  build full $LUNCH_TARGET noclean
  ./prebuilts/sdk/tools/jack-admin kill-server
  cd $OUT
  [ -f "$XOS_VERSION.zip" ] && upload || sendmessage "Build failed." "testers" && exit 1
}

function upload() {
  echo "upload script"
  cd $OUT
  filename="$XOS_VERSION.zip"
  #filename="XOS_jalebi_7.0*.zip"
  ZIP_SIZE_BYTES=$(stat --printf="%s" $filename)
  ZIP_SIZE_MB=$( (ZIP_SIZE_BYTES / 1000000) ) # M
  sendmessage "zip size $ZIP_SIZE_MB MB" "testers"
  [ "$Release" != "true" ] && sendmessage "The build is uploading. Estimated upload duration: 1 minute" "testers"
  echo "Uploading the zip $filename"
  [ "$Release" != "true" ] && rsync -e ssh "$filename" msf-jarvis@frs.sourceforge.net:/home/frs/project/xos-for-jalebi/ || release
  sleep 1
  [ "$2" != "simulate" ] && ret=$? || ret=0
  sleep 4
  [ "$Release" != "true" ] && sendmessage "Build uploaded, use /latest to see it" "testers" && exit 0
  [ "$Release" == "true" ] && tell-them || exit 0
  exit $?
}

function release() {
  wput ftp://"$RELEASE_USER_NAME":"$RELEASE_PASSWD"@halogenos.org/upload/ROM/halogenOS/7/$TARGET_DEVICE/ "$filename"
  [ "$?" == 0 ] || "Uploading of release build failed."
}

function tell-them() {
  sendmessage "This was a release build, will upload in five minutes. download it [here](http://halogenos.org/upload/ROM/halogenOS/7/)" "testers"
  release
}
function init-if-needed() {
  [ -d .repo/ ] || repo init -u git://github.com/halogenOS/android_manifest -b XOS-7.0
}

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export HOST_PREFERS_OWN_CCACHE=true
[ "$TARGET_DEVICE" == "jalebi" ] && export OUT_DIR_COMMON_BASE=/out
mkdir -p xos
cd xos
init-if-needed
build

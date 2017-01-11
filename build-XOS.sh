function sendmessage() {
  tgmessage="$1"
  BOTID="$BOT_TOKEN"
  if [ "$2" == "testers" ]; then
  chat_id="$CHAT_ID"
  else
  chat_id=$2
  fi

  if [ "$2" == "updates" ]; then
  echo "Gonna get some updates for ya"
  fi
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

function build-for-jalebi() {
  . build/envsetup.sh
  if [ "$SYNC" == "true" ]; then reposync turbo;fi
  if [ "$reset" != "false" ]; then reporeset;fi
  if [ "$repopicks" != "none" ]; then repopick "$repopicks";fi
  if [ "$repopick_topic" != "none" ]; then repopick -t "$repopick_topic";fi
  if [ "$?" != 0 ]; then sendmessage "repopick operations failed" "testers" && exit 1; fi
  prebuilts/misc/linux-x86/ccache/ccache -M 30G
  ./prebuilts/sdk/tools/jack-admin kill-server
  sendmessage "Build restarted. This should take about 28 minutes!
  Changelog will come with the build link" "testers"
  if [ "$CLEAN" == "true" ]; then clean="noclean";fi
  build full $LUNCH_TARGET "$clean"
  ./prebuilts/sdk/tools/jack-admin kill-server
  cd $OUT
  if [ -f "$XOS_VERSION.zip" ]; then upload; else sendmessage "Build failed." "testers" && exit 1; fi
}

function upload() {
  echo "upload script"
  filename="$XOS_VERSION.zip"
  ZIP_SIZE_BYTES=$(stat --printf="%s" $filename)
  ZIP_SIZE_MB=$((ZIP_SIZE_BYTES / 1000000)) # M
  sendmessage "zip size $ZIP_SIZE_MB MBs" "testers"
  sendmessage "The build is uploading
  Estimated upload duration: 1 minute" "testers"
  echo "Uploading the zip $filename"
  [ "$2" != "simulate" ] && rsync -e ssh "$filename" msf-jarvis@frs.sourceforge.net:/home/frs/project/xos-for-jalebi/
  sleep 1
  [ "$2" != "simulate" ] && ret=$? || ret=0
  sleep 4
  sendmessage "Build uploaded, use /latest to see it" "testers"
  exit $?
}

function init-if-needed(){
  [ -d .repo/ ] || repo init -u git://github.com/halogenOS/android_manifest -b XOS-7.0
}

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
if [ "$TARGET_DEVICE" == "jalebi" ]; then export OUT_DIR_COMMON_BASE=/out ;fi
cd xos
init-if-needed
build-for-jalebi

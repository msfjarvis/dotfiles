function sendmessage() {
  tgmessage="$1"
  BOTID="$bot_token"
  curl "https://api.telegram.org/bot$BOTID/sendmessage" --data "text=$tgmessage&chat_id=$chat_id&parse_mode=Markdown" &>/dev/null
}

function build() {
  repo sync -c --no-tags build
  . build/envsetup.sh
  rm -rf kernel/ && reposync turbo
  [ "$reset" != "false" ] && reporeset 2>/dev/null
  for task in "$repopick_tasks"; do
    repopick "$task"
  done
  prebuilts/misc/linux-x86/ccache/ccache -M 30G
  ./prebuilts/sdk/tools/jack-admin kill-server
  sendmessage "Build started."
  [ "$CLEAN" == "true" ] && make clean
  breakfast jalebi
  build full XOS_jalebi-userdebug noclean
  ./prebuilts/sdk/tools/jack-admin kill-server
  cd $OUT
  [ -f "$XOS_VERSION.zip" ] && upload || sendmessage "Build failed." && exit 1
}

function upload() {
  echo "upload script"
  cd $OUT
  filename="$XOS_VERSION.zip"
  ZIP_SIZE_BYTES=$(stat --printf="%s" $filename)
  ZIP_SIZE_MB=$( (ZIP_SIZE_BYTES / 1000000) ) # M
  sendmessage "zip size $ZIP_SIZE_MB MB"
  sendmessage "The build is uploading. Estimated upload duration: 1 minute"
  echo "Uploading the zip $filename"
  rsync -e ssh "$filename" msf-jarvis@frs.sourceforge.net:/home/frs/project/xos-for-jalebi/
  ret="$?"
  [ "$ret" == 0 ] || sendmessage "Uploading failed"
  exit $?
}

function init-if-needed() {
  [ -d .repo/ ] || repo init -u git://github.com/halogenOS/android_manifest -b XOS-7.1
}

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export HOST_PREFERS_OWN_CCACHE=true
mkdir -p xos
cd xos
init-if-needed
build

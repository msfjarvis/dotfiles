function sendmessage() {
  tgmessage="$1"
  #BOTID="$bot_token" // we're taking this from the environment now
  curl "https://api.telegram.org/bot$BOTID/sendmessage" --data "text=$tgmessage&chat_id=$chat_id&parse_mode=Markdown" &>/dev/null
}

function build() {
  repo sync -c --no-tags build
  . build/envsetup.sh
  pickAndReset
  prebuilts/misc/linux-x86/ccache/ccache -M 30G
  ./prebuilts/sdk/tools/jack-admin kill-server
  sendmessage "Build started."
  [ "$CLEAN" == "true" ] && make clean
  breakfast "$TARGET_DEVICE"
  build full XOS_"$TARGET_DEVICE"-userdebug noclean
  ./prebuilts/sdk/tools/jack-admin kill-server
  cd $OUT
  [ -f "$XOS_VERSION.zip" ] && upload || sendmessage "Build failed." && return 1
}

function upload() {
  echo "upload script"
  cd $OUT
  filename="$XOS_VERSION.zip"
  ZIP_SIZE_MB=$(du -h $filename | awk '{print $1}' | sed s/M//)
  sendmessage "Uploading the zip $filename"
  sendmessage "zip size $ZIP_SIZE_MB MB"
  sendmessage "Estimated upload duration: 1 minute" #hardcoded time but is always accurate for me
  rsync -e ssh "$filename" msf-jarvis@frs.sourceforge.net:/home/frs/project/xos-for-jalebi/
  ret="$?"
  build_url="https://sourceforget.net/projects/xos-for-jalebi/files/$XOS_VERSION.zip"
  [ "$ret" == 0 ] && sendmessage "[Build]($build_url) uploaded" || sendmessage "Uploading failed"
  return $?
}

function init-if-needed() {
  [ -d .repo/ ] || repo init -u git://github.com/halogenOS/android_manifest -b XOS-7.1
}

function pickAndReset(){
  [ "$reset" == "true" ] && reporeset 2>/dev/null
  temp=$(echo $repopick_tasks | sed s/\n//) #test for empty repopicks list
  if [ "$temp" != "" ]; then
    for task in "$repopick_tasks"; do
      repopick "$task"
    done
  fi
}

function notify(){
  sendmessage "Building for device : $TARGET_DEVICE"
  sleep 0.5
  [ "$CLEAN" == "true" ] && sendmessage "Building clean" || sendmessage "Dirty build"
  sleep 0.5
  temp=$(echo $repopick_tasks | sed s/\n//)
  [ "$temp" != "" ] && sendmessage "repopick tasks : $repopick_tasks" || sendmessage "No repopicks"
}

function testBash(){
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "\033[01;31m"
    echo "Script HAS to be sourced, please DO NOT run it with the bash command!"
    echo -e "\033[0m"
    exit 255
  fi
}

testBash
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export HOST_PREFERS_OWN_CCACHE=true
mkdir -p ~/xos
cd ~/xos
init-if-needed
notify
build

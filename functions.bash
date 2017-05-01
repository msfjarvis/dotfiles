#!/usr/bin/env bash

export AOSP_TAG=android-7.1.1_r25

function mergeaosp() {
  for i in $(cat $1);do echo $i && merge_aosp $i && cd ../;done
}

function merge_aosp() {
        cd $ANDROID_BUILD_TOP
	dir=$1
	repo_name=android_$(echo $dir | sed 's/\//_/g')
	[ -d $repo_name ] || git clone halogenOS/$repo_name
	cd $repo_name
	aospremote
	git fetch aosp --tags
	git merge $AOSP_TAG
}

function add() {
  repo_name=$(printf '%s\n' "${PWD##*/}")
  git remote add gerrit ssh://MSF_Jarvis@review.halogenos.org:29418/$repo_name
  hook
}

function aospremote(){
  repo_name=$(printf '%s\n' "${PWD##*/}")
  repo_name=$(echo $repo_name | sed 's/_/\//g' | sed 's/android/platform/g')
  git remote remove aosp 2>/dev/null
  git remote add aosp https://android.googlesource.com/$repo_name
}

function reposync(){
  git fetch origin XOS-7.1
  git checkout .
  git clean --force
  git reset --hard origin/XOS-7.1
}

function reposyncall(){
  for i in $(ls);do cd $i && reposync && cd ../;done
}

function hook() {
  scp -p -P 29418 MSF_Jarvis@review.halogenos.org:hooks/commit-msg .git/hooks/
}

function gpush() {
  if [ "$1" ]; then git push gerrit HEAD:refs/for/XOS-7.1/"$1"; else git push gerrit HEAD:refs/for/XOS-7.1;fi
}

function gfpush() {
  git push gerrit HEAD:refs/heads/XOS-7.1
}

function gffpush() {
  git push --force gerrit HEAD:refs/heads/XOS-7.1
}

function cleanapks() {
  apks=$(find . -name *.apk 2>/dev/null)
  for i in $apks; do rm $i; done
}

function cleanmahshitz() {
  rm -rf build
  rm -rf app/build
}

function transfer() {
  if [ $# -eq 0 ]
    then echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
    return 1
  fi
  tmpfile=$( mktemp -t transferXXX )
  if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
  curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
  else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile
  fi; cat $tmpfile
  rm -f $tmpfile
}

function immadoandroid() {
  export ANDROID_HOME=/home/msfjarvis/Android/Sdk
}

function gpick(){
  git cherry-pick $@
}


function twrp() {
  #echo $@ && return 1
  if  [ "$1" == "install" ]; then
  if [ "$2" != "" ]; then
  adb push $2 /external_sd/
  adb shell twrp install /external_sd/$2
  else
  echo "install what you twat" && return 1
  fi
  else
  echo "fark orf ya carnt" && return 1
  fi
}

function myeyes() {
  xflux -l 28.6869 -g 77.3525 -r 1 -k 2000
}

function updatee() {
  for i in $(ls); do cd $i && git pull origin XOS-7.0 && cd .. ; done
}

function what() {
  bash-it help aliases $1 | grep $2 2>/dev/null
}

function findapks() {
  find . -name *.apk
}

function list() {
  for i in `cat ~/functions.bash | sed -n "/^[[:blank:]]*function /s/function \([a-z_]*\).*/\1/p" | sort | uniq`; do echo $i ;done
}
immadoandroid
export GOPATH=~/.go

function datime(){
  date '+%A %W %Y %X'
}

function subsupdate(){
  cur_dir=$(pwd)
  cd ~/git-repos/substratum
  git checkout dev
  git pull origin dev
  git checkout self-builds
  git pull origin dev
  git push --all
  cd $cur_dir
}

function weather(){
    if (( `tput cols` < 125 )); then # 125 is min size for correct display
        [ -z "$1" ] && curl "wttr.in/New%20Delhi?0" || curl "wttr.in/$1?0"
    else 
        [ -z "$1" ] && curl "wttr.in/New%20Delhi" || curl "wttr.in/$1"
    fi
}

function serbur(){
  ssh harsh@138.201.198.175
}

function readall(){
  for file in $(ls); do nano $file;done
}

function findtwowords(){
  ag -ia $1 | grep $2
}

function findandopen() {
  for file in $(find . -name $1); do nano $file;done
}

function fetch() {
  [ "$1" == "*app" ]; scp harsh@138.201.198.175:~/xos/out/target/product/jalebi/system/$1/$2/$2.apk .
#  [ "$1" in "zip" ]; scp harsh@138.201.198.175:~/xos/out/target/product/jalebi/$2 .
#  [ "$2" == "*framework*" ]; scp harsh@138.201.198.175:~/xos/out/target/product/jalebi/system/framework/$2 .
#  [ "$2" == "framework-res" ]; scp harsh@138.201.198.175:~/xos/out/target/product/jalebi/system/$1/$2.apk .
#  scp harsh@138.201.198.175:~/xos/out/target/product/jalebi/system/$1 .
}

function tg() {
  curl -F chat_id="$TG_ID" -F document="@$1" "https://api.telegram.org/bot$TG_BOT_ID/sendDocument"
}

function p2d() {
  file=$1
  real_file=`echo $file  | awk -F "/" '{print $NF }'`
  out=$(adb shell find /system -name $real_file)
  if [ "$out" = "" ]
  then
    return "Bad file"
  else
    echo "$file will be placed at $out"
    adb push $file $out
  fi
}

alias disp="xrandr --output eDP1 --rotate $1"
alias wttr=weather
alias xos="cd ~/git-repos/halogenOS"
export PATH=~/bin:$PATH
source ~/bin/bash_completion.d/*
export ANDROID_BUILD_TOP="/home/msfjarvis/git-repos/halogenOS"
alias reload="source ~/.bashrc"
alias funcs="nano ~/functions.bash"


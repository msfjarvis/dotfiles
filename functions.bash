#!/usr/bin/env bash

function add() {
  repo_name=$(printf '%s\n' "${PWD##*/}")
  git remote add gerrit ssh://MSF-Jarvis@review.halogenos.org:29418/$repo_name
  hook
}

function gpush() {
  if [[ ! "$(git remote)" == *"gerrit"* ]]; then
  add
  fi
  git push gerrit HEAD:refs/for/XOS-7.0
}

function gfpush() {
  if [[ ! "$(git remote)" == *"gerrit"* ]]; then
  add
  fi
  git push gerrit HEAD:refs/heads/XOS-7.0
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

function gpick(){
  git cherry-pick $@
}

function jenkinsbuild(){
  if [ $1 ];
  then
  jenkins_invoke -u $JENKINSUSERNAME -p $JENKINSPASSWD -J http://jenkins.msfjarvis.me $1
  else
  echo "Please specify a jenkins job to begin!"
  fi
}

function hook() {
  scp -p -P 29418 MSF-Jarvis@review.halogenos.org:hooks/commit-msg .git/hooks/
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

function myeyes(){
  xflux -l 28.6869 -g 77.3525 -r 1 -k 3000
}

function updatee(){
  for i in $(ls); do cd $i && git pull origin XOS-7.0 && cd .. ; done
}

function what() {
  bash-it help aliases $1 | grep $2 2>/dev/null
}

function findapks(){
  find . -name *.apk
}

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
  [ -z "$1" ] && curl 'wttr.in/New%20Delhi' || curl "wttr.in/$1"
}

alias disp="xrandr --output eDP1 --rotate $1"

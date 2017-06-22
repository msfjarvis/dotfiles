#!/usr/bin/env bash

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

function transfer() {
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

function findapks() {
  find . -name *.apk
}

function list() {
  for i in `cat ~/functions.bash | sed -n "/^[[:blank:]]*function /s/function \([a-z_]*\).*/\1/p" | sort | uniq`; do echo $i ;done
}

function datime(){
  date '+%A %W %Y %X'
}

function weather(){
    if (( `tput cols` < 125 )); then # 125 is min size for correct display
        [ -z "$1" ] && curl "wttr.in/New%20Delhi?0" || curl "wttr.in/$1?0"
    else
        [ -z "$1" ] && curl "wttr.in/New%20Delhi" || curl "wttr.in/$1"
    fi
}

function findandopen() {
  for file in $(find . -name $1); do nano $file;done
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

function tab2space() {
  find .  ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;
}

function d2u() {
  for file in $(find . -type f -not -iwholename '.git'); do dos2unix $file;done
}

function whitespace() {
  find . -type f -not -iwholename '.git' -print0 | xargs -0 perl -pi -e 's/ +$//'
}

alias disp="xrandr --output eDP1 --rotate $1"
alias wttr=weather
export PATH=~/bin:$PATH
source ~/bin/bash_completion.d/*
alias reload="source ~/.bashrc"
alias funcs="nano ~/functions.bash"

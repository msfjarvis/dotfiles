#!/usr/bin/env bash

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache/
export GERRIT_USER=MSF_Jarvis
CL_BOLD="\033[1m"
CL_INV="\033[7m"
CL_RED="\033[01;31m"
CL_RST="\033[0m"
CL_YLW="\033[01;33m"
CL_BLUE="\033[01;34m"

# Gerrit tooling
function getPlatformPath {
  ANDROID_PLATFORM_ROOT="~/xossrc"
  PWD="$(pwd)"
  original_string="$PWD"
  string_to_replace="$ANDROID_PLATFORM_ROOT"
  result_string="${original_string//$string_to_replace}"
  echo -n $result_string
}

function xg {
  original_string="$(getPlatformPath)"
  original_string=$(echo  $original_string | cut -d "/" -f5-)
  strepl="_"
  resultstr="android_${original_string//\//$strepl}"

  git remote remove gerrit 2>/dev/null
  git remote add gerrit https://$GERRIT_USER@review.halogenos.org/a/$resultstr
#  git remote add gerrit ssh://$GERRIT_USER@review.halogenos.org:29418/$resultstr
  hook_path=$(git rev-parse --git-dir)/hook/commit-msg
  [[ -f $hook_path ]] || hook
}

function hook {
  curl -kLo `git rev-parse --git-dir`/hooks/commit-msg https://MSF_Jarvis@review.halogenos.org/tools/hooks/commit-msg
  chmod +x `git rev-parse --git-dir`/hooks/commit-msg
}

function gpush {
  [[ $1 ]] || BRANCH="XOS-8.0" && BRANCH="$1"
  echo "${GERRIT_PASSWD}"
  if [ "$2" ]; then
  git push gerrit HEAD:refs/for/$BRANCH/"$2"
  else
  git push gerrit HEAD:refs/for/$BRANCH
  fi
}

function gfpush {
   [[ $1 ]] || BRANCH="XOS-8.0" && BRANCH="$1"
  echo "${GERRIT_PASSWD}"
  git push gerrit HEAD:refs/heads/$BRANCH
}

function gffpush {
  echo "${GERRIT_PASSWD}"
  git push --force gerrit HEAD:refs/heads/XOS-8.0
}

function createXos {
  original_string="$(getPlatformPath)"
  original_string=$(echo  $original_string | cut -d "/" -f5-)
  strepl="_"
  resultstr="android_${original_string//\//$strepl}"
  echo $resultstr
  ssh ${GERRIT_USER}@review.halogenos.org -p 29418 gerrit create-project -p All-Projects -t REBASE_IF_NECESSARY $resultstr
  git create halogenOS/${resultstr}
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



# Server tooling
function startserver {
  gcloud compute instances start --project "halogenos-msfjarvis" --zone "us-west1-c" "jarvisbox"
}

function stopserver {
  gcloud compute instances stop --project "halogenos-msfjarvis" --zone "us-west1-c" "jarvisbox"
}

function serverconnect {
  gcloud compute --project "halogenos-msfjarvis" ssh --zone "us-west1-c" "jarvisbox"
}


# Telegram stuff
function tg {
    chat_id="${2}"
    [[ "${2}" == "" ]] && chat_id="${MSF_TG_ID}"
    curl -F chat_id="${chat_id}" -F document="@${1}" "https://api.telegram.org/bot${TG_BOT_ID}/sendDocument" >&2
}

function tgm {
    chat_id="${2}"
    [[ "${2}" == "" ]] && chat_id="${MSF_TG_ID}"
    curl -F chat_id="${chat_id}" -F text="${1}" "https://api.telegram.org/bot${TG_BOT_ID}/sendMessage" >&2
}

function pushcaesiumtg {
    tg "zips/${1}" "${OP3_TESTERS_CHAT_ID}"
    tgm "${2}" "${OP3_TESTERS_CHAT_ID}"
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
        [ -z "$1" ] && curl "wttr.in/New%20Delhi?0" || curl "wttr.in/$1?0"
    else
        [ -z "$1" ] && curl "wttr.in/New%20Delhi" || curl "wttr.in/$1"
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

function what {
  grep $1 ~/.bash_aliases
}


# Android + Kernel stuff
function p2d {
  adb shell mount system
  final_path=$(adb shell find /system -name $1)
  echo "${final_path}"
  adb push $1 "${final_path}"
  adb shell umount system
}

function pushcaesium {
  adb push zips/$1 /sdcard/Caesium/
}

function kgrep {
    find . -name .git -prune -o -path ./out -prune -o -regextype posix-egrep \
        -iregex '(.*\/Makefile|.*\/Kconfig|.*\/oneplus3_defconfig|.*\/caesium_defconfig)' -type f \
        -exec grep --color -n "$@" {} +
}

function kerndeploy {
    git push msf;gfpush;git push gerrit HEAD:refs/heads/XOS-7.1
}


# File sanitization
function tab2space {
  find .  ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;
}

function d2u {
  for file in $(find . -type f -not -iwholename '.git'); do dos2unix $file;done
}

function whitespace {
  find . -type f -not -iwholename '.git' -print0 | xargs -0 perl -pi -e 's/ +$//'
}


# List all functions
function list {
    local all_functions=""
    for function in $(cat ~/bin/functions.bash |sed -n "/^[[:blank:]]*function /s/function \([a-z_]*\).*/\1/p" | sort | uniq);do
        all_functions="${all_functions} ${function}"
    done
    echo "${all_functions}"
}

alias disp="xrandr --output eDP1 --rotate $1"
alias reload="source ~/.bashrc"
alias funcs="nano ~/bin/functions.bash"

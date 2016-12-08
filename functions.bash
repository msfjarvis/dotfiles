#!/usr/bin/env bash

function cleanapks() {
  apks=$(find . -name *.apk 2>/dev/null)
  echo "$(echo $apks | wc -l) APKs found"
  for i in $apks; do rm $i; done
}

function cleanmahshitz() {
  rm -rf build
  rm -rf app/build
}

# kanged from transfer.sh, but oh well I did the formatting by hand
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
  jenkins_invoke -u $JENKINSUSERNAME -p $JENKINSPASSWD -J $JENKINSURL $1
  else
  echo "Please specify a jenkins job to begin!"
  fi
}

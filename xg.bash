function xg() {
  original_string="$(getPlatformPath)"
  strepl="_"
  resultstr="android_${original_string//\//$strepl}"
  
  local AT="$@"
  
  local remotebranchaddition=""
  
  if [ ! -z "$topic" ]; then
    local remotebranchaddition="/$topic"
  fi  
  
  if [ ! -z "$message" ]; then
    local remotebranchaddition="$remotebranchaddition%message=$message"
  fi
  
  case $1 in
    add)
      git remote add gerrit ssh://MSF-Jarvis@review.halogenos.org:29418/$resultstr
      ;;
    addf)
      xg add
      xg fetch
      xg u
      ;;
    fetch)
      git fetch gerrit
      ;;
    u)
      shift
      local tp="$(git branch | grep \* | cut -d ' ' -f2)"
      if [ ! -z "$1" ]; then
        tp="$1"
        shift
      fi
      git branch -u gerrit/$tp
      ;;
    push)
      xg ih
      shift
      if [[ ! "$(git remote -v)" == *"review.halogenos"* ]] || [[ ! "$(git remote)" == *"gerrit"* ]]; then
        xg addf
      fi
      git push gerrit "HEAD:refs/for/$(git branch | grep \* | cut -d ' ' -f2)${remotebranchaddition}%submit" $@
      xg u
      ;;
    dcpush)
      xg ih
      shift
      if [[ ! "$(git remote -v)" == *"review.halogenos"* ]] || [[ ! "$(git remote)" == *"gerrit"* ]]; then
        xg addf
      fi
      local f_first="$1"
      shift
      git push gerrit "$f_first:refs/heads/$(git branch | grep \* | cut -d ' ' -f2)${remotebranchaddition}" $@
      xg u
      ;;
    cpush)
      xg ih
      shift
      if [[ ! "$(git remote -v)" == *"review.halogenos"* ]] || [[ ! "$(git remote)" == *"gerrit"* ]]; then
        xg addf
      fi
      local f_first="$1"
      shift
      git push gerrit "$f_first:refs/for/$(git branch | grep \* | cut -d ' ' -f2)${remotebranchaddition}%submit" $@
      xg u
      ;;
    dpush)
      xg ih
      shift
      if [[ ! "$(git remote -v)" == *"review.halogenos"* ]] || [[ ! "$(git remote)" == *"gerrit"* ]]; then
        xg addf
      fi
      git push gerrit "$(git branch | grep \* | cut -d ' ' -f2)${remotebranchaddition}" $@
      xg u
      ;;
    cr)
      xg ih
      shift
      local tp="$(git branch | grep \* | cut -d ' ' -f2)"
      if [ ! -z "$1" ]; then
        tp="$1"
        shift
      fi
      if [[ ! "$(git remote -v)" == *"review.halogenos"* ]] || [[ ! "$(git remote)" == *"gerrit"* ]]; then
        xg addf
      fi
      git push gerrit "HEAD:refs/for/$tp${remotebranchaddition}" $@
      xg u
      ;;
    crc)
      xg ih
      shift
      if [[ ! "$(git remote -v)" == *"review.halogenos"* ]] || [[ ! "$(git remote)" == *"gerrit"* ]]; then
        xg addf
      fi
      git push gerrit "$1:refs/for/$(git branch | grep \* | cut -d ' ' -f2)${remotebranchaddition}" $@
      xg u
      ;;
    ih)
      gitdir=$(git rev-parse --git-dir)
      if [ ! -e ${gitdir}/hooks/commit-msg ]; then
        scp -p -P 29418 xdevs23@review.halogenos.org:hooks/commit-msg ${gitdir}/hooks/
      fi
      ;;
    *) echo "Oops";;
  esac
  
  unset message
  unset topic
  unset remotebranchaddition
  unset AT
}

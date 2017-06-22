rom=""
gapps=""
themeready_gapps=""

declare -a zips=("${rom}" "${gapps}" "${themeready_gapps}")

function pushall() {
    echo "${1}"
    adb push "${1}" /external_sd/
}

function flashall() {
    echo "${1}"
    adb shell twrp install /external_sd/"${1}"
}

function wipeall() {
    echo "${1}"
    adb shell rm /external_sd/"${1}"
}

[ "${1}" ] && for target in ${@};do adb shell twrp wipe ${target};done

for zip in ${zips[@]}; do
pushall "$zip"
flashall "$zip"
wipeall "$zip"
done

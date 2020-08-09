#!/usr/bin/env bash

shopt -s nullglob

VERSION="0.0.2-beta"
DIR_RAW=${1:-.}
DIR=$(realpath "${DIR_RAW}" )
TMPFILE1=$(mktemp)

display_usage() {
    echo -e "renamed.sh v.${VERSION}\n"
    echo "Script to batch rename files in a directory using your text editor."
    echo "WARNING: Use at your own risk."
    echo -e "\nUsage:\n\trenamed.sh [directory]\n"
}

if [  $# -le 0 ]
then
    display_usage
    exit 1
fi

# get list of files in the directory
BASEDIR="$PWD"
FILES_BEFORE=()
cd "${DIR}" || exit
for entry in *
do
    if [ -f "$(realpath "${DIR}")/${entry}" ]; then
        echo "$entry" >> "${TMPFILE1}"
        FILES_BEFORE+=("$entry")
    fi
done
cd "${BASEDIR}" || exit

# open file list in editor
"${EDITOR:-vi}" "${TMPFILE1}"

# Ceck result
mapfile -t FILES_AFTER < "${TMPFILE1}"

BEFORE_COUNT=${#FILES_BEFORE[@]}
AFTER_COUNT=${#FILES_AFTER[@]}

if [ "$AFTER_COUNT" != "$BEFORE_COUNT" ]; then
    echo "The number of files before [$BEFORE_COUNT] and after [$AFTER_COUNT] is different"
    exit 2
fi

declare -A COMMANDS
for (( i = 0 ; i < BEFORE_COUNT ; i++))
do
    BEFORE=$(realpath "${DIR}")/${FILES_BEFORE[$i]}
    AFTER=$(realpath "${DIR}")/${FILES_AFTER[$i]}
    if [ "$BEFORE" != "$AFTER" ]; then
        echo "mv -n -v ${BEFORE} ${AFTER}"
        COMMANDS[$BEFORE]=$AFTER
    fi
done

# cleanup
rm "${TMPFILE1}"

# Check if there is somehting to do
if [ ${#COMMANDS[@]} -eq 0 ]; then
    echo "Nothing to do ... exiting"
    exit 1
fi

read -p "Are you sure? [y|N]:" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for before in "${!COMMANDS[@]}"
    do
        mv -n -v "${before}" "${COMMANDS[$before]}"
    done
fi
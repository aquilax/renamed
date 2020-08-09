#!/bin/bash

VERSION="0.0.1-beta"
DIR=${1:-.}
TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)

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
# TODO: exclude direvtories
ls -1 -A -N "${DIR}" > "${TMPFILE1}"
cp "${TMPFILE1}" "${TMPFILE2}"

# open file list in editor
"${EDITOR:-vi}" "${TMPFILE1}"

# show diff
# TODO: open diff only if the files have different content
diff "${TMPFILE1}" "${TMPFILE2}" | less

# Ceck result
mapfile -t FILES_BEFORE < "${TMPFILE2}"
mapfile -t FILES_AFTER < "${TMPFILE1}"

BEFORE_COUNT=${#FILES_BEFORE[@]}
AFTER_COUNT=${#FILES_AFTER[@]}

if [ "$AFTER_COUNT" != "$BEFORE_COUNT" ]; then
    echo "The number of files before [$BEFORE_COUNT] and after [$AFTER_COUNT] is different"
    exit 1
fi

for (( i = 0 ; i < BEFORE_COUNT ; i++))
do
    BEFORE=$(realpath "${DIR}")/${FILES_BEFORE[$i]}
    AFTER=$(realpath "${DIR}")/${FILES_AFTER[$i]}
    if [ "$BEFORE" != "$AFTER" ]; then
        # TODO: Add dry run mode
        mv -n "${BEFORE}" "${AFTER}"
    fi
done

# cleanup
rm "${TMPFILE1}" "${TMPFILE2}"
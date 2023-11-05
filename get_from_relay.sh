#!/bin/bash
set -euo pipefail

# TODO: absolute path
LOCAL_DIR_SAVE="./from_relay"
RELAY_SERVER="mys:~/termux-inbox"

# --mkpath 
rsync --remove-source-files --ignore-missing-args \
    "$RELAY_SERVER/*" \
    "$LOCAL_DIR_SAVE/"

# decrypt
gpg -q --decrypt-files $LOCAL_DIR_SAVE/*.gpg \
    && rm $LOCAL_DIR_SAVE/*.gpg

# untar, if have any
shopt -s nullglob
(cd $LOCAL_DIR_SAVE && \
    for file in ./*.tar; do
        echo a
        tar -xvf "$file" --one-top-level;
    done && rm -f ./*.tar)

ls -1 $LOCAL_DIR_SAVE

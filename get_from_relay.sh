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
gpg -q --decrypt-files $LOCAL_DIR_SAVE/*.gpg
# untar, if have any
(cd $LOCAL_DIR_SAVE && \
    for file in *.tar; do
        tar -xvf "$file" --one-top-level;
    done)


rm $LOCAL_DIR_SAVE/*.gpg $LOCAL_DIR_SAVE/*.tar

ls -1 $LOCAL_DIR_SAVE

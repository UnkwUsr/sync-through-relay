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
tar xvf $LOCAL_DIR_SAVE/*.tar -C $LOCAL_DIR_SAVE --one-top-level

rm $LOCAL_DIR_SAVE/*.gpg $LOCAL_DIR_SAVE/*.tar

ls -1 $LOCAL_DIR_SAVE

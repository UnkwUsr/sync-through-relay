#!/bin/bash
set -euo pipefail

# TODO: absolute path
LOCAL_DIR_SAVE="./from_relay"
RELAY_SERVER="mys:~/termux-inbox"

# --mkpath 
rsync --remove-source-files --ignore-missing-args \
    "$RELAY_SERVER/*" \
    "$LOCAL_DIR_SAVE/"
gpg -q --decrypt-files $LOCAL_DIR_SAVE/*.gpg
rm $LOCAL_DIR_SAVE/*.gpg

ls -1 $LOCAL_DIR_SAVE

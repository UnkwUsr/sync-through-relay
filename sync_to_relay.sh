#!/bin/bash
set -euo pipefail

INBOX_FOLDER="$HOME/device/txts/phone_inbox"
LOCAL_DIR_SENT="$HOME/device/txts/phone_inbox_sent"

RELAY_SERVER="mys:~/termux-inbox"
GPG_ID="for-termux-inbox"

# crypt content of folder and send. If ok, then sent content moved to "sent"
# folder (just in case, instead of deleting)
crypt_and_send() {
    src="$1"
    if [ ! -e "$src" ]; then
        echo "WARN: $src does not exist, skipping"
        return
    fi

    time="$EPOCHSECONDS"
    crypted="$TMPDIR/${time}.tar.gpg"
    tar cv -C "$src" . | gpg --encrypt --recipient "$GPG_ID" -o "$crypted"

    scp "$crypted" "$RELAY_SERVER/" \
        || (echo "can't send: $time" >> "$src/errors" && exit 1)
    rm "$crypted"

    mkdir -p "$LOCAL_DIR_SENT"
    mv -n "$src" "$LOCAL_DIR_SENT/$time"
}

crypt_and_send "$INBOX_FOLDER"

echo
echo "all done. Press enter"
read -r

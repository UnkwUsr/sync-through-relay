#!/bin/bash
set -euo pipefail

INBOX_FOLDER="$HOME/device/txts/phone_inbox"

INBOX_MD="$INBOX_FOLDER/inbox.md"
INBOX_VOICES="$INBOX_FOLDER/voices/"
LOCAL_DIR_SENT="$INBOX_FOLDER/sent"

RELAY_SERVER="mys:~/termux-inbox"
GPG_ID="for-termux-inbox"

append_time() {
    if [ -d "$1" ]; then
        echo "${1}_$EPOCHSECONDS"
    else
        echo "${EPOCHSECONDS}_$1"
    fi
}

crypt_into() {
    src="$1"
    new="$2"
    if [ -d "$src" ]; then
        crypted="$TMPDIR/$new.tar.gpg"
        (cd "$src" && \
            gpgtar --encrypt -o "$crypted" --recipient $GPG_ID ./*)
    else
        crypted="$TMPDIR/$new.gpg"
        gpg --encrypt -o "$crypted" --recipient $GPG_ID "$src"
    fi
    echo "$crypted"
}

# crypt, send and move to folder "sent" (just in case)
crypt_and_send() {
    src="$1"
    if [ ! -e "$src" ]; then
        echo "WARN: $src does not exist, skipping"
        return
    fi

    timed_name="$(append_time "$(basename "$src")")"

    crypted=$(crypt_into "$src" "$timed_name")

    scp "$crypted" "$RELAY_SERVER/" \
        || (echo >> "$INBOX_MD" && echo "can't send" && exit 1)
    rm "$crypted"

    mkdir -p "$LOCAL_DIR_SENT"
    mv -n "$src" "$LOCAL_DIR_SENT/$timed_name"
}

crypt_and_send "$INBOX_MD"
crypt_and_send "$INBOX_VOICES"

echo
echo "all done. Press enter"
read -r

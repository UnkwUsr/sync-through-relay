#!/bin/bash
set -euo pipefail

# TODO: absolute path
PHONE_INBOX="$HOME/device/phone_inbox.md"
LOCAL_DIR_SENT="$HOME/device/sent"
SYNC_TARGET="mys:~/termux-inbox"
GPG_ID="for-termux-inbox"

newfilename="inbox_$EPOCHSECONDS.md"
cryptedfile=$(mktemp -u)
# crypt
gpg --encrypt -o "$cryptedfile" --recipient $GPG_ID "$PHONE_INBOX"
# send
scp "$cryptedfile" "$SYNC_TARGET/$newfilename.gpg" \
    || (echo >> "$PHONE_INBOX" && exit 1)
# remove crypted temp file
rm "$cryptedfile"

sentfile="$LOCAL_DIR_SENT/$newfilename"
mkdir -p "$LOCAL_DIR_SENT"
mv -n "$PHONE_INBOX" "$sentfile"

# TODO: god, should gurantee that sync did well
# UPD: would like to live some time with it, see how it goes, later can add. Ok
# rm "$SYNC_DIR_FROM/$newfilename"

echo
echo "all done. Press enter"
read -r

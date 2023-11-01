#!/bin/bash
set -euo pipefail

# TODO: absolute path
PHONE_INBOX="$HOME/device/phone_inbox.md"
PHONE_VOICES="$HOME/device/inbox_voices/"
LOCAL_DIR_SENT="$HOME/device/sent"
SYNC_TARGET="mys:~/termux-inbox"
GPG_ID="for-termux-inbox"

newfilename="inbox_$EPOCHSECONDS.md"
newfilename_voices="voices_$EPOCHSECONDS"
cryptedfile=$(mktemp -u)
crypted_voices=$(mktemp -u)
# crypt
gpg --encrypt -o "$cryptedfile" --recipient $GPG_ID "$PHONE_INBOX"
# crypt voices
gpgtar --encrypt -o "$crypted_voices" --recipient $GPG_ID \
    -C "$(dirname "$PHONE_VOICES")" "$(basename "$PHONE_VOICES")"
# send
scp "$cryptedfile" "$SYNC_TARGET/$newfilename.gpg" \
    || (echo >> "$PHONE_INBOX" && exit 1)
# send voices
scp "$crypted_voices" "$SYNC_TARGET/$newfilename_voices.tar.gpg" \
    || (echo -e "\ncant send voices\n" >> "$PHONE_INBOX" && exit 1)
# remove crypted temp files
rm "$cryptedfile" "$crypted_voices"

mkdir -p "$LOCAL_DIR_SENT"
# move inbox to sent
mv -n "$PHONE_INBOX" "$LOCAL_DIR_SENT/$newfilename"
# move voices to sent
mv "$PHONE_VOICES" "$LOCAL_DIR_SENT/$newfilename_voices"

# TODO: god, should gurantee that sync did well
# UPD: would like to live some time with it, see how it goes, later can add. Ok
# rm "$SYNC_DIR_FROM/$newfilename"

echo
echo "all done. Press enter"
read -r

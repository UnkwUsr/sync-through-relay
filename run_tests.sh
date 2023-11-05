#!/bin/bash
# shellcheck disable=SC2155 # declare and assign separately
# shellcheck disable=SC2064

SYNC_TO_RELAY=$(realpath ./sync_to_relay.sh)
GET_FROM_RELAY=$(realpath ./get_from_relay.sh)

export TEST_RELAY_SERVER="mys:sync-test"
export TMPDIR=${TMPDIR:-/tmp/}

reset_faketime() {
    FAKE_TIME="1698778040"
}
faketime_tick() {
    time=$(date +'%F %T' -d "@$FAKE_TIME")
    faketime -f "@$time" "$1"
    FAKE_TIME=$((FAKE_TIME + 1))
}

run_test() {
    set -euo pipefail
    pushd "$1" > /dev/null
    echo "-------- Running test $(basename "$1") --------"
    echo

    rm -rf test_env && mkdir test_env
    reset_faketime

    test_sync_to_relay
    test_get_from_relay

    popd > /dev/null
}

test_sync_to_relay() {
    echo "Testing sync_to_relay"

    mkdir -p test_env/source/sent
    # run each as if it would be separate syncs
    for num in source/*/; do
        echo "sync_num: $num"

        export TEST_INBOX_FOLDER="$(realpath test_env/"$num")"
        cp -r "$num" test_env/source/
        faketime_tick "$SYNC_TO_RELAY" <<<"y" > /dev/null

        mv test_env/"${num}"/sent/* test_env/source/sent
        rm -r test_env/"$num"
    done

    diff -r test_env/source expected/source_new

    echo
}

test_get_from_relay() {
    echo "Testing get_from_relay"

    (cd test_env && $GET_FROM_RELAY > /dev/null)
    diff -r test_env/from_relay expected/from_relay

    echo
}

for tst in ./tests/*; do
    run_test "$tst"
done

#!/bin/bash
set -euxo pipefail
komodod -ac_name=NINJA -ac_supply=100000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -pubkey=${PUBKEY} &
sleep 5 &
tail -f /home/komodian/.komodo/NINJA/debug.log

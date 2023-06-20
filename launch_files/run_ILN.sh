#!/bin/bash
set -euxo pipefail
komodod -ac_name=ILN -ac_supply=10000000000 -ac_cc=2 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=51.75.122.83 -pubkey=${PUBKEY} &
sleep 5 &
tail -f /home/komodian/.komodo/ILN/debug.log

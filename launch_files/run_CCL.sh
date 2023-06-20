#!/bin/bash
set -euxo pipefail
komodod -ac_name=CCL -ac_supply=200000000 -ac_end=1 -ac_cc=2 -addressindex=1 -spentindex=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=142.93.136.89 -addnode=195.201.22.89 -pubkey=${PUBKEY} &
sleep 5 &
tail -f /home/komodian/.komodo/CCL/debug.log

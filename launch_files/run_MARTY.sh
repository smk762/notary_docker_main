#!/bin/bash
set -euxo pipefail
komodod -ac_name=MARTY -ac_supply=90000000000 -ac_reward=100000000 -ac_cc=3 -ac_staked=10 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=65.21.77.109 -addnode=65.21.51.47 -pubkey=${PUBKEY} &
sleep 5 &
tail -f /home/komodian/.komodo/MARTY/debug.log

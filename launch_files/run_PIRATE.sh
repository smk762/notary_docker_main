#!/bin/bash
set -euxo pipefail
komodod -ac_name=PIRATE -ac_supply=0 -ac_reward=25600000000 -ac_halving=77777 -ac_private=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=88.99.212.81 -pubkey=${PUBKEY} &
sleep 5 &
tail -f /home/komodian/.komodo/PIRATE/debug.log

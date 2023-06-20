#!/bin/bash
set -euxo pipefail
komodod -ac_name=GLEEC -ac_supply=210000000 -ac_public=1 -ac_staked=100 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=95.217.161.126 -pubkey=${PUBKEY} &
sleep 5 &
tail -f /home/komodian/.komodo/GLEEC/debug.log

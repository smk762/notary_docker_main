#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=NINJA stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=NINJA /home/smk762/.komodo/NINJA/BASE_komodo-cli -ac_name=NINJA
# Running NINJA daemon
exec komodod -ac_name=NINJA -ac_supply=100000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/NINJA/debug.log & wait

set +x
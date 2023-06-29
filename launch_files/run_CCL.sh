#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=CCL stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=CCL /home/smk762/.komodo/CCL/BASE_komodo-cli -ac_name=CCL
# Running CCL daemon
exec komodod -ac_name=CCL -ac_supply=200000000 -ac_end=1 -ac_cc=2 -addressindex=1 -spentindex=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=142.93.136.89 -addnode=195.201.22.89 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/CCL/debug.log & wait

set +x
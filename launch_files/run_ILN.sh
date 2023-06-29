#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=ILN stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=ILN /home/smk762/.komodo/ILN/BASE_komodo-cli -ac_name=ILN
# Running ILN daemon
exec komodod -ac_name=ILN -ac_supply=10000000000 -ac_cc=2 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=51.75.122.83 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/ILN/debug.log & wait

set +x
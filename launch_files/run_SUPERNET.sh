#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=SUPERNET stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=SUPERNET /home/smk762/.komodo/SUPERNET/BASE_komodo-cli -ac_name=SUPERNET
# Running SUPERNET daemon
exec komodod -ac_name=SUPERNET -ac_supply=816061 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/SUPERNET/debug.log & wait

set +x
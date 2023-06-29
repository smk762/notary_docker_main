#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=GLEEC stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=GLEEC /home/smk762/.komodo/GLEEC/BASE_komodo-cli -ac_name=GLEEC
# Running GLEEC daemon
exec komodod -ac_name=GLEEC -ac_supply=210000000 -ac_public=1 -ac_staked=100 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=95.217.161.126 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/GLEEC/debug.log & wait

set +x
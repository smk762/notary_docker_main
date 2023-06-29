#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=KOIN stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=KOIN /home/smk762/.komodo/KOIN/BASE_komodo-cli -ac_name=KOIN
# Running KOIN daemon
exec komodod -ac_name=KOIN -ac_supply=125000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=3.0.32.10 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/KOIN/debug.log & wait

set +x
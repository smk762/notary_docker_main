#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=DOC stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=DOC /home/smk762/.komodo/DOC/BASE_komodo-cli -ac_name=DOC
# Running DOC daemon
exec komodod -ac_name=DOC -ac_supply=90000000000 -ac_reward=100000000 -ac_cc=3 -ac_staked=10 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=65.21.77.109 -addnode=65.21.51.47 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/DOC/debug.log & wait

set +x
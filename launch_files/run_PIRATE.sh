#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=PIRATE stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=PIRATE /home/smk762/.komodo/PIRATE/BASE_komodo-cli -ac_name=PIRATE
# Running PIRATE daemon
exec komodod -ac_name=PIRATE -ac_supply=0 -ac_reward=25600000000 -ac_halving=77777 -ac_private=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=88.99.212.81 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/PIRATE/debug.log & wait

set +x
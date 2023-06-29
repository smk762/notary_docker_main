#!/usr/bin/env bash
set -x

trap 'komodo-cli -ac_name=THC stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli -ac_name=THC /home/smk762/.komodo/THC/BASE_komodo-cli -ac_name=THC
# Running THC daemon
exec komodod -ac_name=THC -ac_supply=251253103 -ac_reward=360000000,300000000,240000000,180000000,150000000,90000000,0 -ac_staked=100 -ac_eras=7 -ac_end=500001,1000001,1500001,2000001,2500001,4500001,0 -ac_perc=233333333 -ac_cc=2 -ac_ccenable=229,236,240 -ac_script=2ea22c8020987fad30df055db6fd922c3a57e55d76601229ed3da3b31340112e773df3d0d28103120c008203000401ccb8 -ac_founders=150 -ac_cbmaturity=1 -ac_sapling=1 -earlytxid=7e4a76259e99c9379551389e9f757fc5f46c33ae922a8644dc2b187af2a6adc1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=157.230.45.184 -addnode=165.22.52.123 -addnode=15.235.204.174 -addnode=148.113.1.52 -addnode=65.21.77.109 -pubkey=${PUBKEY} &
tail -f /home/smk762/.komodo/THC/debug.log & wait

set +x
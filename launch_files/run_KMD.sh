#!/usr/bin/env bash
set -x

trap 'komodo-cli stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_komodo-cli /home/smk762/.komodo/BASE_komodo-cli
# Running KMD daemon
exec komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf" &
tail -f /home/smk762/.komodo/debug.log & wait

set +x
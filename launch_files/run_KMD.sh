#!/bin/bash
set -euxo pipefail
komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf" &
cp /usr/local/bin/komodo-cli /home/komodian/.komodo/komodo-cli
sleep 300 &
tail -f /home/komodian/.komodo/debug.log

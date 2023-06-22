#!/bin/bash
set -ex
cp /usr/local/bin/komodo-cli /home/komodian/.komodo/komodo-cli
exec komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf"

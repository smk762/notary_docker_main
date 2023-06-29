#!/usr/bin/env bash
set -x

trap 'litecoin-cli stop'  SIGHUP SIGINT SIGTERM

cp /home/komodian/BASE_litecoin-cli /home/smk762/.litecoin/BASE_litecoin-cli
# Running LTC daemon
exec litecoind -pubkey=${PUBKEY} &
tail -f /home/smk762/.litecoin/debug.log & wait

set +x
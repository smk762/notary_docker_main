#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli stop
  echo "KMD daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running KMD daemon
exec komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf" &
~/.komodo/debug.log

set +x
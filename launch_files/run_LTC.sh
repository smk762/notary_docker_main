#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  litecoin-cli stop
  echo "LTC daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running LTC daemon
exec litecoind -pubkey=${PUBKEY} &
~/.litecoin/debug.log

set +x
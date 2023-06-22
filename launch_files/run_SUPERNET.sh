#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=SUPERNET stop
  echo "SUPERNET daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running SUPERNET daemon
exec komodod -ac_name=SUPERNET -ac_supply=816061 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -pubkey=${PUBKEY} &
~/.komodo/SUPERNET/debug.log

set +x
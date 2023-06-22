#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=CCL stop
  echo "CCL daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running CCL daemon
exec komodod -ac_name=CCL -ac_supply=200000000 -ac_end=1 -ac_cc=2 -addressindex=1 -spentindex=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=142.93.136.89 -addnode=195.201.22.89 -pubkey=${PUBKEY} &
~/.komodo/CCL/debug.log

set +x
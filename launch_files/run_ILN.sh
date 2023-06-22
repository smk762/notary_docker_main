#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=ILN stop
  echo "ILN daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running ILN daemon
exec komodod -ac_name=ILN -ac_supply=10000000000 -ac_cc=2 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=51.75.122.83 -pubkey=${PUBKEY} &
~/.komodo/ILN/debug.log

set +x
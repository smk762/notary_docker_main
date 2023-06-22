#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=NINJA stop
  echo "NINJA daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running NINJA daemon
exec komodod -ac_name=NINJA -ac_supply=100000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -pubkey=${PUBKEY} &
~/.komodo/NINJA/debug.log

set +x
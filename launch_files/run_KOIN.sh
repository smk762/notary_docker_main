#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=KOIN stop
  echo "KOIN daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running KOIN daemon
exec komodod -ac_name=KOIN -ac_supply=125000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=3.0.32.10 -pubkey=${PUBKEY} &
~/.komodo/KOIN/debug.log

set +x
#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=GLEEC stop
  echo "GLEEC daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running GLEEC daemon
exec komodod -ac_name=GLEEC -ac_supply=210000000 -ac_public=1 -ac_staked=100 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=95.217.161.126 -pubkey=${PUBKEY} &
~/.komodo/GLEEC/debug.log

set +x
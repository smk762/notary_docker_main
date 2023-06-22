#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=DOC stop
  echo "DOC daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running DOC daemon
exec komodod -ac_name=DOC -ac_supply=90000000000 -ac_reward=100000000 -ac_cc=3 -ac_staked=10 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=65.21.77.109 -addnode=65.21.51.47 -pubkey=${PUBKEY} &
~/.komodo/DOC/debug.log

set +x
#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  pid=$(pgrep komodod)
  komodo-cli -ac_name=PIRATE stop
  echo "PIRATE daemon terminated with PID ${pid}…"
  wait "$pid"
  exit 777;
}

trap 'sigterm_handler' SIGTERM


# Running PIRATE daemon
exec komodod -ac_name=PIRATE -ac_supply=0 -ac_reward=25600000000 -ac_halving=77777 -ac_private=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=88.99.212.81 -pubkey=${PUBKEY} &
~/.komodo/PIRATE/debug.log

set +x
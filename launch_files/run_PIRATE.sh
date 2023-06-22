#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  if [ $pid -ne 0 ]; then
    komodo-cli -ac_name=PIRATE stop
    kill -TERM "$pid"
    echo "PIRATE daemon terminated…"
    wait "$pid"
  fi
  exit 777;
}

trap 'kill ${!}; sigterm_handler' TERM

# Running PIRATE daemon
komodod -ac_name=PIRATE -ac_supply=0 -ac_reward=25600000000 -ac_halving=77777 -ac_private=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=88.99.212.81 -pubkey=${PUBKEY} &
pid="$!"
echo "PID=$pid"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done

set +x
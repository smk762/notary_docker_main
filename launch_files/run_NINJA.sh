#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  if [ $pid -ne 0 ]; then
    komodo-cli -ac_name=NINJA stop
    kill -TERM "$pid"
    echo "NINJA daemon terminated…"
    wait "$pid"
  fi
  exit 777;
}

trap 'kill ${!}; sigterm_handler' TERM

# Running NINJA daemon
komodod -ac_name=NINJA -ac_supply=100000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -pubkey=${PUBKEY} &
pid="$!"
echo "PID=$pid"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done

set +x
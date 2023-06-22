#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  if [ $pid -ne 0 ]; then
    komodo-cli -ac_name=CCL stop
    kill -TERM "$pid"
    echo "CCL daemon terminated…"
    wait "$pid"
  fi
  exit 777;
}

trap 'kill ${!}; sigterm_handler' TERM

# Running CCL daemon
komodod -ac_name=CCL -ac_supply=200000000 -ac_end=1 -ac_cc=2 -addressindex=1 -spentindex=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=142.93.136.89 -addnode=195.201.22.89 -pubkey=${PUBKEY} &
pid="$!"
echo "PID=$pid"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done

set +x
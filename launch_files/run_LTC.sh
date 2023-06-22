#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  if [ $pid -ne 0 ]; then
    litecoin-cli stop
    kill -TERM "$pid"
    echo "LTC daemon terminated…"
    wait "$pid"
  fi
  exit 777;
}

trap 'kill ${!}; sigterm_handler' TERM

# Running LTC daemon
litecoind -pubkey=${PUBKEY} &
pid="$!"
echo "PID=$pid"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done

set +x
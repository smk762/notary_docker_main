#!/usr/bin/env bash
set -x

pid=0

sigterm_handler() {
  echo "sigterm handler called…"
  if [ $pid -ne 0 ]; then
    komodo-cli stop
    kill -TERM "$pid"
    echo "KMD daemon terminated…"
    wait "$pid"
  fi
  exit 777;
}

trap 'kill ${!}; sigterm_handler' TERM

# Running KMD daemon
komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf" &
pid="$!"
echo "PID=$pid"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done

set +x
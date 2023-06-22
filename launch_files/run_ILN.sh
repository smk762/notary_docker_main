#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  komodo-cli -ac_name=ILN stop
  while true; do
    sleep 1
    blocks=$(komodo-cli -ac_name=ILN getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

komodod -ac_name=ILN -ac_supply=10000000000 -ac_cc=2 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=51.75.122.83 -pubkey=${PUBKEY} &
tail -f ~/.komodo/ILN/debug.log &

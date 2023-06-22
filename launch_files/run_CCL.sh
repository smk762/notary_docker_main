#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  komodo-cli -ac_name=CCL stop
  while true; do
    sleep 1
    blocks=$(komodo-cli -ac_name=CCL getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

komodod -ac_name=CCL -ac_supply=200000000 -ac_end=1 -ac_cc=2 -addressindex=1 -spentindex=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=142.93.136.89 -addnode=195.201.22.89 -pubkey=${PUBKEY} &
tail -f ~/.komodo/CCL/debug.log &

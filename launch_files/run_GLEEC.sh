#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  komodo-cli -ac_name=GLEEC stop
  while true; do
    sleep 1
    blocks=$(komodo-cli -ac_name=GLEEC getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

komodod -ac_name=GLEEC -ac_supply=210000000 -ac_public=1 -ac_staked=100 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=95.217.161.126 -pubkey=${PUBKEY} &
tail -f ~/.komodo/GLEEC/debug.log &

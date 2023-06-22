#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  komodo-cli -ac_name=SUPERNET stop
  while true; do
    sleep 1
    blocks=$(komodo-cli -ac_name=SUPERNET getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

komodod -ac_name=SUPERNET -ac_supply=816061 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -pubkey=${PUBKEY} &
tail -f ~/.komodo/SUPERNET/debug.log &

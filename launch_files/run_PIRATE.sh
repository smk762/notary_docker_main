#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  komodo-cli -ac_name=PIRATE stop
  while true; do
    sleep 1
    blocks=$(komodo-cli -ac_name=PIRATE getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

komodod -ac_name=PIRATE -ac_supply=0 -ac_reward=25600000000 -ac_halving=77777 -ac_private=1 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=88.99.212.81 -pubkey=${PUBKEY} &
tail -f ~/.komodo/PIRATE/debug.log &

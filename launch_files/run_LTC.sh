#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  litecoin-cli stop
  while true; do
    sleep 1
    blocks=$(litecoin-cli getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

litecoind -pubkey=${PUBKEY} &
tail -f ~/.litecoin/debug.log &

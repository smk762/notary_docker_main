#!/bin/bash
set -ex
function exit_script(){
  echo "Caught stop signal..."
  komodo-cli stop
  while true; do
    sleep 1
    blocks=$(komodo-cli getblockcount)
    if [ ${#blocks} -eq 0 ]; then
      break
    fi
    echo ${blocks}
  done
  exit 0
}

trap exit_script SIGTERM SIGKILL SIGQUIT

komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf" &
tail -f ~/.komodo/debug.log &

#!/bin/bash

if [[ -z ${1} ]]; then
    read -p "Enter coin ticker: " coin
else
    coin=$1
fi

if [[ "$coin" == "LTC" ]] then
    tail -f ~/.litecoin/debug.log
elif [[ "$coin" == "KMD" ]] then
    tail -f ~/.komodo/debug.log
else
    tail -f ~/.komodo/${coin}/debug.log
fi

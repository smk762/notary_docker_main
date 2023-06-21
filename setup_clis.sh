#!/bin/bash

./configure.py clis
~/dPoW/iguana/listassetchains | while read coin; do
    sudo ln -s /home/$USER/.komodo/${coin}/${coin}-cli /usr/local/bin/${coin}-cli
done

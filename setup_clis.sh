#!/bin/bash

./configure.py clis
sudo ln -s /home/$USER/.komodo/komodo-cli /usr/local/bin/komodo-cli
sudo ln -s /home/$USER/.litecoin/litecoin-cli /usr/local/bin/litecoin-cli
./listassetchains | while read coin; do
    sudo ln -s /home/$USER/.komodo/${coin}/${coin}-cli /usr/local/bin/${coin}-cli
done

#!/bin/bash

# Setup cli binary symlinks
./configure.py clis
sudo ln -sf /home/$USER/.komodo/komodo-cli /usr/local/bin/komodo-cli
sudo ln -sf /home/$USER/.litecoin/litecoin-cli /usr/local/bin/litecoin-cli
./listassetchains | while read coin; do
    sudo ln -sf /home/$USER/.komodo/${coin}-cli /usr/local/bin/${coin}-cli
done

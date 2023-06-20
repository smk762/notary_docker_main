#!/bin/python3

./configure.py
~/dPoW/iguana/listassetchains | while read chain; do
    sudo ln -s /home/$USER/.komodo/${coin}/${coin}-cli /usr/local/bin/${coin}-cli
done


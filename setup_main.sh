#!/bin/bash

source pubkey.txt
if test -z "$pubkey"
then
  read -p "Enter your pubkey: " pubkey
  # TODO: validate pubkey
  echo "pubkey=${pubkey}" > pubkey.txt
fi

mkdir -p /home/${USER}/.zcash-params
./fetch-params.sh

rm assetchains.json
wget https://raw.githubusercontent.com/KomodoPlatform/dPoW/season-seven/iguana/assetchains.json

echo "Setting up .env file..."
USER_ID=$(id -u)
GROUP_ID=$(id -g)
echo "PUBKEY=${pubkey}" > .env
echo "USER_ID=${USER_ID}" >> .env
echo "GROUP_ID=${GROUP_ID}" >> .env

echo "Updating docker-compose.yml..."
./configure.py yaml
sed "s/USERNAME/${USER}/gi" -i "docker-compose.yml"

echo "Setting up conf files and data folders..."
./configure.py confs

# Initialising debug log files
echo "" > /home/$USER/.komodo/debug.log
echo "" > /home/$USER/.litecoin/debug.log
./listassetchains | while read coin; do
    echo "" > /home/$USER/.komodo/${coin}/debug.log
done

echo "Setting up launch files..."
./configure.py launch

echo "Building docker images..."
docker compose build

# Initialising cli binaries log files
./configure.py clis
sudo ln -sf /home/$USER/.komodo/komodo-cli /usr/local/bin/komodo-cli
sudo ln -sf /home/$USER/.litecoin/litecoin-cli /usr/local/bin/litecoin-cli
./listassetchains | while read coin; do
    sudo ln -sf /home/$USER/.komodo/${coin}/${coin}-cli /usr/local/bin/${coin}-cli
done

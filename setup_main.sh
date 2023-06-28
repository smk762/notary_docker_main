#!/bin/bash

# Setup pubkey
source pubkey.txt
if test -z "$pubkey"
then
  read -p "Enter your pubkey: " pubkey
  # TODO: validate pubkey
  echo "pubkey=${pubkey}" > pubkey.txt
fi

# Get zcash params
mkdir -p /home/${USER}/.zcash-params
./fetch-params.sh

# Setup env variables
echo "Setting up .env file..."
USER_ID=$(id -u)
GROUP_ID=$(id -g)
echo "PUBKEY=${pubkey}" > .env
echo "USER_ID=${USER_ID}" >> .env
echo "GROUP_ID=${GROUP_ID}" >> .env

./update_main.sh

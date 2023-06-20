#!/bin/bash

echo "Updating repository..."
git pull

echo "Updating docker-compose.yml  (in case of new coins..."
./configure.py yaml
sed "s/USERNAME/${USER}/gi" -i "docker-compose.yml"

echo "Setting up conf files and data folders (in case of new coins)..."
./configure.py confs

echo "Setting up daemon clis (in case of new coins)..."
./configure.py clis
~/dPoW/iguana/listassetchains | while read chain; do
    sudo ln -s /home/$USER/.komodo/${coin}/${coin}-cli /usr/local/bin/${coin}-cli
done

if [ -z "$1" ]
  then
    echo "Building docker images..."
    docker compose build $@
    ./stop_main.sh
    ./start_main.sh
  else
    echo "Building docker images..."
    docker compose build $1 $@
    ./stop_main.sh $1
    ./start_main.sh $1 
fi

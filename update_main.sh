#!/bin/bash

# Update repo
git pull

# Initialising docker-compose yaml
./configure.py yaml
sed "s/USERNAME/${USER}/gi" -i "docker-compose.yml"

# Initialising conf files log files
./configure.py confs

echo "Setting up launch files (in case of new coins)..."
./configure.py launch

# Initialising cli binaries log files
./configure.py clis
~/dPoW/iguana/listassetchains | while read chain; do
    sudo ln -s /home/$USER/.komodo/${coin}/${coin}-cli /usr/local/bin/${coin}-cli
done

# Initialising debug log files
echo "" > /home/$USER/.komodo/debug.log
~/dPoW/iguana/listassetchains | while read chain; do
    echo "" > /home/$USER/.komodo/${coin}/debug.log
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

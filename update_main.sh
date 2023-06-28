#!/bin/bash

# Update repo
git pull

rm assetchains.json
wget https://raw.githubusercontent.com/KomodoPlatform/dPoW/season-seven/iguana/assetchains.json

# Initialising docker-compose yaml
echo "Setting up docker-compose yaml file..."
./configure.py yaml
sed "s/USERNAME/${USER}/gi" -i "docker-compose.yml"

# Initialising conf & debug.log files
echo "Setting up conf files..."
./configure.py confs

# Creating launch files
echo "Setting up launch files..."
./configure.py launch

# Build daemons
if [ -z "$1" ]; then
  echo "Stopping daemons..."
  docker compose stop
  echo "Building daemons..."
  docker compose build
else
  echo "Stopping $1 daemon..."
  docker compose stop $1
  echo "Building $1 daemon..."
  docker compose build $1
fi

# Initialising cli binaries & log files
./configure.py clis
./setup_clis.sh

if [ -z "$1" ]; then
  echo "Update complete! Run ./start_main.sh $1 to launch the $1 daemon container."
else
  echo "Update complete! Run ./start_main.sh to launch the daemon containers."
fi
#!/bin/bash

generate_random_string() {
  local length=$1
  local output=""
  exec 10< /dev/urandom
  while (( ${#output} < length )); do
    read -n $length -u 10 str
    str=$(tr -dc 'a-zA-Z0-9' <<< "$str")
    output="$output$str"
  done
  output=${output:0:$length}
  echo "$output"
  exec 10<&-
}

source /home/${USER}/dPoW/iguana/pubkey.txt
if test -z "$pubkey"
then
  read -p "Enter your pubkey: " pubkey
  # TODO: validate pubkey
  echo "pubkey=${pubkey}" > /home/${USER}/dPoW/iguana/pubkey.txt
fi

echo "Setting up .env file..."
USER_ID=$(id -u)
GROUP_ID=$(id -g)
echo "PUBKEY=${pubkey}" > .env
echo "USER_ID=${USER_ID}" >> .env
echo "GROUP_ID=${GROUP_ID}" >> .env

echo "Updating docker-compose.yml..."
cp docker-compose.template docker-compose.yml
sed "s/USERNAME/${USER}/gi" -i "docker-compose.yml"

echo "Setting up conf files and data folders..."

./configure.py confs

echo "Building docker images..."
docker compose build

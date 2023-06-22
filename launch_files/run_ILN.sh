#!/bin/bash
set -ex
exec komodod -ac_name=ILN -ac_supply=10000000000 -ac_cc=2 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=51.75.122.83 -pubkey=${PUBKEY}

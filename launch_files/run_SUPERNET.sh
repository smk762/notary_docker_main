#!/bin/bash
set -ex
exec komodod -ac_name=SUPERNET -ac_supply=816061 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=209.222.101.247 -addnode=103.195.100.32 -pubkey=${PUBKEY}

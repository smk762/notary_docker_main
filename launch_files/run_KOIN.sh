#!/bin/bash
set -ex
exec komodod -ac_name=KOIN -ac_supply=125000000 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=3.0.32.10 -pubkey=${PUBKEY}
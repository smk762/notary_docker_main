#!/bin/bash
set -ex
exec komodod -ac_name=CLC -ac_supply=99000000 -ac_reward=50000000 -ac_perc=100000000 -ac_founders=1 -ac_cc=45 -ac_public=1 -ac_snapshot=1440 -ac_pubkey=02df9bda7bfe2bcaa938b29a399fb0ba58cfb6cc3ddc0001062a600f60a8237ad9 -ac_adaptivepow=6 -addnode=209.222.101.247 -addnode=103.195.100.32 -addnode=node.cryptocollider.com -pubkey=${PUBKEY}

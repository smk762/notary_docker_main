#!/bin/bash

set -euxo pipefail
echo $PWD
echo "========================================"
cd ~
git clone https://github.com/litecoin-project/litecoin
git checkout beae01d # https://github.com/litecoin-project/litecoin/tree/v0.21.4
# apply patches from PR#990 to build dependencies with gcc-11
wget https://github.com/litecoin-project/litecoin/pull/990.diff
git apply -v 990.diff
# build as described here https://komodoplatform.com/en/docs/notary/
make -C ${PWD}/depends v=1 NO_PROTON=1 NO_QT=1 HOST=$(depends/config.guess) -j$(nproc --all)
./autogen.sh
CXXFLAGS="-g0 -O2" CONFIG_SITE="$PWD/depends/$(depends/config.guess)/share/config.site" ./configure --disable-tests --disable-bench --without-miniupnpc -enable-experimental-asm --with-gui=no --disable-bip70
make V=1 -j$(nproc --all)
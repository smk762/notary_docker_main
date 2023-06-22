#!/bin/bash

set -euxo pipefail
echo $PWD
echo "========================================"
git clone https://github.com/litecoin-project/litecoin -b 0.16
cd litecoin && git checkout ${1}
make -C ${PWD}/depends v=1 NO_PROTON=1 NO_QT=1 HOST=$(depends/config.guess) -j$(nproc --all)
./autogen.sh
CXXFLAGS="-g0 -O2" \
CONFIG_SITE="$PWD/depends/$(depends/config.guess)/share/config.site" ./configure --disable-tests --disable-bench --without-miniupnpc --enable-experimental-asm --with-gui=no --disable-bip70
make V=1 -j$(nproc --all)
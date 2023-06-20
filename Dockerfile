FROM ubuntu:20.04
LABEL maintainer="smk@komodoplatform.com"

# Setup up user and working directory
ARG COMMIT_HASH
ARG GROUP_ID
ARG USER_ID
RUN addgroup --gid ${GROUP_ID} notarygroup
RUN adduser --disabled-password --gecos '' --uid ${USER_ID} --gid ${GROUP_ID} komodian
WORKDIR /home/komodian

ARG BUILD_PACKAGES="libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev curl \
        libboost-test-dev libboost-thread-dev build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev python3-zmq \
        zlib1g-dev wget bsdmainutils automake cmake clang libsodium-dev libcurl4-gnutls-dev libssl-dev git unzip python jq htop"

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive 
RUN apt update && apt install $BUILD_PACKAGES -y

# Build 
COPY build.sh /build.sh
RUN /build.sh "${COMMIT_HASH}"

# Move binaries
RUN mv /home/komodian/komodo/src/komodo-cli /usr/local/bin/komodo-cli
RUN mv /home/komodian/komodo/src/komodod /usr/local/bin/komodod
RUN PATH=/usr/local/bin/:$PATH

# Cleanup
RUN rm -rf /home/komodian/komodo
RUN apt remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && \
    rm -rf /var/lib/apt/lists/* 
RUN apt update && apt install -y wget nano htop libgomp1 libcurl3-gnutls-dev telnet

COPY entrypoint.sh /entrypoint.sh
COPY launch_files/ /

# Setup user and working directory
RUN chown -R komodian:notarygroup /home/komodian
USER komodian

ENTRYPOINT ["/entrypoint.sh"]

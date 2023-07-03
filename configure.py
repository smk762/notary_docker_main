#!/usr/bin/env python3
import shutil
import requests
import secrets
import json
import sys
import os
import helper
from const import HOME, SCRIPT_PATH, COINS_DATA, LAUNCH_PARAMS, \
                COINS_DATA, DOCKER_COINS, IS_INSIGHT_EXPLORER, \
                ADDRESS_WHITELIST, DAEMON_PEERS, IS_NOTARY
from based_58 import get_addr_from_pubkey


def create_cli_wrapper(coin: str) -> None:
    host_cli = helper.get_cli(coin, False)
    container_cli = helper.get_cli(coin, True)
    wrapper = f"cli_wrappers/{host_cli}"
    with open(wrapper, 'w') as conf:
        conf.write('#!/bin/bash\n')
        conf.write(f'docker exec -it {coin.lower()} {container_cli} "$@"\n')
        os.chmod(wrapper, 0o755)


def create_launch_file(coin: str) -> None:
    launch_file = f"docker_files/launch_files/run_{coin}.sh"
    with open(launch_file, 'w') as f:
        with open('templates/launch.template', 'r') as t:
            for line in t.readlines():
                line = line.replace('COIN', coin)
                line = line.replace('CLI', helper.get_cli(coin, True))
                line = line.replace('DEBUG', helper.get_debug(coin, True))
                line = line.replace('LAUNCH', helper.get_launch_params(coin))
                f.write(line)
        os.chmod(launch_file, 0o755)


def create_conf(coin: str, txindex: int=1, addressindex: int=0, spentindex: int=1, timestampindex=0) -> None:
    '''
    Creates a TICKER.conf file on the host. `addressindex=1` is incompatible 
    with the DexStats bootstraps. If you want to use the bootstrap, without a reindex,
    don't change the indexes. For block explorers, all indexes should be set to 1.
    '''
    if IS_INSIGHT_EXPLORER:
        txindex = 1
        addressindex = 1
        spentindex = 1
        timestampindex = 1

    # Create conf file if not existing
    data_path = helper.get_data_path(coin, False)
    if not os.path.exists(data_path):
        os.makedirs(data_path)

    # Create debug.log file if not existing
    debug_file = helper.get_debug(coin, False)
    if not os.path.exists(debug_file):
        with open(debug_file, 'w') as f:
            f.write('')

    # TODO: Change this once can a static host IP is set in docker
    rpcip = "0.0.0.0"
    conf_file = helper.get_conf(coin, False)
    rpcuser, rpcpass = helper.get_rpc_creds(conf_file)
    pubkey = helper.get_pubkey(coin)
    p2pport = COINS_DATA[coin]["p2pport"]
    rpcport = COINS_DATA[coin]["rpcport"] or p2pport + 1
    zmqport = COINS_DATA[coin]["zmqport"] or p2pport + 2
    zmq_url = f"tcp://{rpcip}:{zmqport}"
    with open(conf_file, 'w') as conf:
        # Auth creds for RPC
        conf.write(f'rpcuser={rpcuser}\n')
        conf.write(f'rpcpassword={rpcpass}\n')
        # Maintain an index of all addresses and balances.
        conf.write(f'addressindex={addressindex}\n')
        # Maintain an index of all spent transactions.
        conf.write(f'spentindex={spentindex}\n')
        # Maintain an index of all transactions.
        conf.write(f'txindex={txindex}\n')
        # Maintain an index of timestamps for all block hashes.
        conf.write(f'timestampindex={timestampindex}\n')
        if IS_INSIGHT_EXPLORER:
            conf.write(f'zmqpubrawtx={zmq_url}\n')
            conf.write(f'zmqpubhashblock={zmq_url}\n')
            conf.write(f'uacomment=bitcore\n')
            conf.write(f'showmetrics=0\n')

        # Required for JSON RPC commands
        conf.write('server=1\n')
        # Run in the background as a daemon and accept commands
        conf.write('daemon=1\n')
        # Sets the depth of the work queue to service RPC calls, the default is 16.
        # We set this higher for notary nodes
        conf.write('rpcworkqueue=256\n')
        # Instructs the daemon to listen for json-rpc connections. Can be set multiple times.
        conf.write(f'rpcbind={rpcip}:{rpcport}\n')
        # Instructs the daemon which ip addresses are approved for RPC. Can be set multiple times.
        conf.write(f'rpcallowip={rpcip}/0\n')
        # Defines the P2P port. This port should be open to the public for propagation of block data.
        conf.write(f'port={p2pport}\n')
        # Defines the RPC port. This port should be protected from the public with a firewall.
        conf.write(f'rpcport={rpcport}\n')
        # Adds a few notaries as peers to the daemons
        for k, v in DAEMON_PEERS.items():
            conf.write(f'addnode={v} # {k}\n')            
        # For Antara smartchains and Komodo forks, an address whitelist is available to restrict 
        # recieving funds to a specific set of addresses. This mitigates spam attacks.
        if helper.is_smartchain(coin):
            for k, v in ADDRESS_WHITELIST.items():
                address = get_addr_from_pubkey(pubkey, coin)
                if address != "":
                    conf.write(f'whitelistaddress={v} # {k}\n')
            conf.write(f'whitelistaddress={address} # User KMD address\n')
            print(f"PLEASE MANUALLY ADD ANY ADDITIONAL {coin} WHITELIST ADDRESSES TO `const.py`!")


def get_service_yaml(coin: str) -> None:
    rpcport = COINS_DATA[coin]["rpcport"]
    p2pport = COINS_DATA[coin]["p2pport"]
    yaml = []
    yaml.append(f'  {coin.lower()}:\n')
    yaml.append('    env_file:\n')
    yaml.append('      - .env\n')
    yaml.append('    build:\n')
    yaml.append('      context: ./docker_files\n')
    yaml.append(f'      dockerfile: {helper.get_dockerfile(coin)}\n')
    yaml.append('      args:\n')
    yaml.append('        - USER_ID=$USER_ID\n')
    yaml.append('        - GROUP_ID=$GROUP_ID\n')
    yaml.append(f'        - COMMIT_HASH={helper.get_commit_hash(coin)}\n')
    yaml.append(f'        - SERVICE_CLI="{helper.get_cli(coin, True)}"\n')
    yaml.append('    ports:\n')
    yaml.append(f'      - "127.0.0.1:{p2pport}:{p2pport}"\n')
    yaml.append(f'      - "127.0.0.1:{rpcport}:{rpcport}"\n')
    yaml.append('    volumes:\n')
    if helper.is_smartchain(coin):
        yaml.append('      - <<: *zcash-params\n')
    yaml.append(f'      - {helper.get_data_path(coin, False)}:{helper.get_data_path(coin, True)}\n')
    yaml.append(f"    container_name: {coin.lower()}\n")
    yaml.append('    restart: always\n')
    yaml.append('    stop_grace_period: 15s\n')
    yaml.append('    logging:\n')
    yaml.append('      driver: "json-file"\n')
    yaml.append('      options:\n')
    yaml.append('        max-size: "20m"\n')
    yaml.append('        max-file: "10"\n')
    yaml.append(f'    command: ["/run.sh"]\n')
    yaml.append('\n')
    return yaml


def create_cli_wrappers() -> None:
    for coin in DOCKER_COINS:
        create_cli_wrapper(coin)


def create_launch_files() -> None:
    for coin in DOCKER_COINS:
        create_launch_file(coin)
    if "KMD" not in DOCKER_COINS:
        create_launch_file("KMD")


def create_confs() -> None:
    for coin in DOCKER_COINS:
        create_conf(coin)


def create_compose_yaml() -> None:
    shutil.copy('templates/docker-compose.template', 'docker-compose.yml')
    with open('docker-compose.yml', 'a+') as conf:
        for coin in DOCKER_COINS:
            conf.writelines(get_service_yaml(coin))
            

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('No arguments given, exiting.')
    elif sys.argv[1] == 'clis':
        create_cli_wrappers()
    elif sys.argv[1] == 'confs':
        create_confs()
    elif sys.argv[1] == 'launch':
        create_launch_files()
    elif sys.argv[1] == 'yaml':
        create_compose_yaml()
    else:
        print('Invalid option, must be in ["clis", "confs", "launch", "yaml]')

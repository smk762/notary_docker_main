#!/usr/bin/env python3
import string
import shutil
import secrets
import json
import sys
import os

# Get the list of coins

home = os.path.expanduser('~')

with open(f'assetchains.json') as file:
    assetchains = json.load(file)

coins_main = {
    "CCL": {
        "p2pport": 20848,
        "rpcport": 20849
    },
    "KMD": {
        "p2pport": 7770,
        "rpcport": 7771
    },
    "LTC": {
        "p2pport": 9333,
        "rpcport": 9332
    },
    "CLC": {
        "p2pport": 20931,
        "rpcport": 20932
    },
    "GLEEC": {
        "p2pport": 23225,
        "rpcport": 23226
    },
    "ILN": {
        "p2pport": 12985,
        "rpcport": 12986
    },
    "NINJA": {
        "p2pport": 8426,
        "rpcport": 8427
    },
    "KOIN": {
        "p2pport": 10701,
        "rpcport": 10702
    },
    "PIRATE": {
        "p2pport": 45452,
        "rpcport": 45453
    },
    "SUPERNET": {
        "p2pport": 11340,
        "rpcport": 11341
    },
    "THC": {
        "p2pport": 36789,
        "rpcport": 36790
    },
    "DOC": {
        "p2pport": 62415,
        "rpcport": 62416
    },
    "MARTY": {
        "p2pport": 52592,
        "rpcport": 52593
    }
}

coins = list(coins_main.keys())


def format_param(param, value):
    return f'-{param}={value}'


def generate_rpc_pass(length=24):
    special_chars = "@~-_|():+"
    rpc_chars = string.ascii_letters + string.digits + special_chars
    return "".join(secrets.choice(rpc_chars) for _ in range(length))


def get_launch_string(coin):
    if coin == 'LTC':
        return f"litecoind -pubkey=${{PUBKEY}}"
    if coin == 'KMD':
        return f'komodod -pubkey=${{PUBKEY}} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf"'
    for i in assetchains:
        if i["ac_name"] == coin:
            params = []
            for param, value in i.items():
                if isinstance(value, list):
                    for dupe_value in value:
                        params.append(format_param(param, dupe_value))
                else:
                    params.append(format_param(param, value))
            launch_str = ' '.join(params)
            return f"komodod {launch_str} -pubkey=${{PUBKEY}}"


def get_cli_command(coin) -> str:
    if coin == 'LTC':
        return f"litecoin-cli"
    elif coin == 'KMD':
        return f"komodo-cli"
    else:
        return f"komodo-cli -ac_name={coin}"


def get_debug_path(coin) -> str:
    if coin == 'LTC':
        return f"{home}/.litecoin/debug.log"
    elif coin == 'KMD':
        return f"{home}/.komodo/debug.log"
    else:
        return f"{home}/.komodo/{coin}/debug.log"


def create_cli_wrappers():
    for coin in coins:
        with open(f"{home}/.komodo/{coin}-cli", 'w') as conf:
            if coin != 'KMD':
                conf.write('#!/bin/bash\n')
                conf.write(f"komodo-cli -ac_name={coin} $@\n")
                os.chmod(f"{home}/.komodo/{coin}-cli", 0o755)


def create_launch_files():
    for coin in coins:
        launch_file = f"launch_files/run_{coin}.sh"
        launch = get_launch_string(coin)
        cli = get_cli_command(coin)
        base_cli = cli.split(' ')[0]
        conf_path = os.path.split(get_conf_path(coin))[0]
        debug = get_debug_path(coin)
        with open(launch_file, 'w') as f:
            with open('templates/launch.template', 'r') as t:
                for line in t.readlines():
                    line = line.replace('CLI', cli)
                    line = line.replace('COIN', coin)
                    line = line.replace('DEBUG', debug)
                    line = line.replace('LAUNCH', launch)
                    line = line.replace('BASE_CLI', base_cli)
                    line = line.replace('CONF_PATH', conf_path)
                    f.write(line)
            os.chmod(launch_file, 0o755)


def get_conf_path(coin):
    if coin == 'LTC':
        conf_file = f"{home}/.litecoin/litecoin.conf"
    elif coin == 'KMD':
        conf_file = f"{home}/.komodo/komodo.conf"
    else:
        conf_file = f"{home}/.komodo/{coin}/{coin}.conf"
    return conf_file


def create_confs():
    for coin in coins:
        rpcuser = generate_rpc_pass()
        rpcpass = generate_rpc_pass()
        conf_file = get_conf_path(coin)
        # Get conf file path
        folder = os.path.split(conf_file)[0]
        if not os.path.exists(folder):
            os.makedirs(folder)
        # Use existing rpcuser and rpcpass if they exist
        if os.path.exists(conf_file):
            with open(conf_file, 'r') as f:
                lines = f.readlines()
                for line in lines:
                    if line.startswith('rpcuser'):
                        rpcuser = line.split('=')[1].strip()
                    if line.startswith('rpcpassword'):
                        rpcpass = line.split('=')[1].strip()
            
        with open(conf_file, 'w') as conf:
            conf.write(f'rpcuser={rpcuser}\n')
            conf.write(f'rpcpassword={rpcpass}\n')
            conf.write('txindex=1\n')
            conf.write('addressindex=1\n')
            conf.write('spentindex=1\n')
            conf.write('server=1\n')
            conf.write('daemon=1\n')
            conf.write('rpcworkqueue=256\n')
            conf.write(f'rpcbind=0.0.0.0:{coins_main[coin]["rpcport"]}\n')
            conf.write('rpcallowip=0.0.0.0/0\n')
            conf.write(f'port={coins_main[coin]["p2pport"]}\n')
            conf.write(f'rpcport={coins_main[coin]["rpcport"]}\n')
            conf.write('addnode=77.75.121.138 # Dragonhound_AR\n')
            conf.write('addnode=209.222.101.247 # Dragonhound_NA\n')
            conf.write('addnode=103.195.100.32 # Dragonhound_DEV\n')
            conf.write('addnode=104.238.221.61\n')
            conf.write('addnode=199.127.60.142\n')
        # create debug.log files if not existing
        debug_file = get_debug_path(coin)
        debug_path = os.path.split(debug_file)[0]
        if not os.path.exists(debug_path):
            os.makedirs(debug_path)
        if not os.path.exists(debug_file):
            with open(debug_file, 'w') as f:
                f.write('')



def create_compose_yaml(server='3p'):
    if server == '3p':
        shutil.copy('templates/docker-compose.template_3p', 'docker-compose.yml')
    else:
        # Not yet used in 3P repo
        shutil.copy('templates/docker-compose.template_main', 'docker-compose.yml')
        with open('docker-compose.yml', 'a+') as conf:
            for coin in coins_main:
                if coin == 'KMD':
                    cli = "komodo-cli"
                else:
                    cli = f"komodo-cli -ac_name={coin}"
                p2pport = coins_main[coin]["p2pport"]
                rpcport = coins_main[coin]["rpcport"]
                conf.write(f'  {coin.lower()}:\n')
                conf.write('    env_file:\n')
                conf.write('      - .env\n')
                conf.write('    build:\n')
                conf.write('      context: ./docker_files\n')
                conf.write('      dockerfile: Dockerfile.KMD\n')
                conf.write('      args:\n')
                conf.write('        - USER_ID=$USER_ID\n')
                conf.write('        - GROUP_ID=$GROUP_ID\n')
                conf.write('        - COMMIT_HASH=156dba6\n')
                conf.write(f'        - SERVICE_CLI="{cli}"\n')
                conf.write('    ports:\n')
                conf.write(f'      - "127.0.0.1:{p2pport}:{p2pport}"\n')
                conf.write(f'      - "127.0.0.1:{rpcport}:{rpcport}"\n')
                conf.write('    volumes:\n')
                conf.write('      - <<: *zcash-params\n')      
                if coin == "KMD":
                    conf.write('      - /home/USERNAME/.komodo:/home/komodian/.komodo\n')
                else:
                    conf.write(f'      - /home/USERNAME/.komodo/{coin}:/home/komodian/.komodo/{coin}\n')
                conf.write(f"    container_name: {coin.lower()}\n")
                conf.write("    shm_size: '2gb'\n")
                conf.write('    restart: always\n')
                conf.write('    stop_grace_period: 10s\n')
                conf.write('    logging:\n')
                conf.write('      driver: "json-file"\n')
                conf.write('      options:\n')
                conf.write('        max-size: "20m"\n')
                conf.write('        max-file: "10"\n')
                conf.write(f'    command: ["/run.sh"]\n')
                conf.write('\n')


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
        print('Invalid option, must be in ["clis", "confs", "launch"]')

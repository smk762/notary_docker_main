#!/bin/python3
import string
import shutil
import secrets
import json
import sys
import os

# Get the list of coins

home = os.path.expanduser('~')

with open(f'{home}/dPoW/iguana/assetchains.json') as file:
    assetchains = json.load(file)

main_ports = {
    "CCL": {
        "p2pport": 20848,
        "rpcport": 20849
    },
    "KMD": {
        "p2pport": 7770,
        "rpcport": 7771
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

coins = list(main_ports.keys())


def format_param(param, value):
    return f'-{param}={value}'


def get_launch_string(coin):
    print(coin)
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
            return f"komodod {launch_str} -pubkey=${{PUBKEY}} &"


def generate_rpc_pass(length=24):
    special_chars = "@~-_|():+"
    rpc_chars = string.ascii_letters + string.digits + special_chars
    return "".join(secrets.choice(rpc_chars) for _ in range(length))


def create_clis():
    for coin in coins:
        with open(f"{home}/.komodo/{coin}-cli", 'w') as conf:
            if coin != 'KMD':
                conf.write('#!/bin/bash\n')
                conf.write(f"komodo-cli -ac_name={coin} $@\n")
        os.chmod(f"{home}/.komodo/{coin}-cli", 0o755)


def create_launch_files():
    for coin in coins:
        filename = f"launch_files/run_{coin}.sh"
        with open(filename, 'w') as conf:
            if coin == 'KMD':
                conf.write('#!/bin/bash\n')
                conf.write("set -euxo pipefail\n")
                conf.write('komodod -pubkey=${PUBKEY} -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=".litecoin/litecoin.conf" &\n')
                conf.write("cp /usr/local/bin/komodo-cli /home/komodian/.komodo/komodo-cli\n")
                conf.write("sleep 300 &\n")
                conf.write("tail -f /home/komodian/.komodo/debug.log\n")
            else:
                conf.write('#!/bin/bash\n')
                conf.write("set -euxo pipefail\n")
                conf.write(f"{get_launch_string(coin)}\n")
                conf.write("sleep 5 &\n")
                conf.write(f"tail -f /home/komodian/.komodo/{coin}/debug.log\n")
            os.chmod(filename, 0o755)


def create_confs():
    for coin in coins:
        if coin == 'KMD':
            filename = f"{home}/.komodo/komodo.conf"
        else:
            filename = f"{home}/.komodo/{coin}/{coin}.conf"
        folder = os.path.split(filename)[0]
        if not os.path.exists(folder):
            os.makedirs(folder)            
        with open(filename, 'w') as conf:
            conf.write(f'rpcuser={generate_rpc_pass()}\n')
            conf.write(f'rpcpassword={generate_rpc_pass()}\n')
            conf.write('txindex=1\n')
            conf.write('addressindex=1\n')
            conf.write('spentindex=1\n')
            conf.write('server=1\n')
            conf.write('daemon=1\n')
            conf.write('rpcworkqueue=256\n')
            conf.write('rpcbind=127.0.0.1\n')
            conf.write('rpcallowip=127.0.0.1\n')
            conf.write(f'port={main_ports[coin]["p2pport"]}\n')
            conf.write(f'rpcport={main_ports[coin]["rpcport"]}\n')
            conf.write('addnode=77.75.121.138 # Dragonhound_AR\n')
            conf.write('addnode=209.222.101.247 # Dragonhound_NA\n')
            conf.write('addnode=103.195.100.32 # Dragonhound_DEV\n')
            conf.write('addnode=104.238.221.61\n')
            conf.write('addnode=199.127.60.142\n')


def create_compose_yaml():
    shutil.copy('docker-compose.template', 'docker-compose.yml')
    with open('docker-compose.yml', 'a+') as conf:
        for coin in coins:
            p2pport = main_ports[coin]["p2pport"]
            rpcport = main_ports[coin]["rpcport"]
            conf.write(f'  {coin.lower()}:\n')
            conf.write('    <<: *komodod-base\n')
            conf.write(f'    command: /run_{coin}.sh\n')
            conf.write('    ports:\n')
            conf.write(f'      - "127.0.0.1:{p2pport}:{p2pport}"\n')
            conf.write(f'      - "127.0.0.1:{rpcport}:{rpcport}"\n')
            conf.write('    volumes:\n')
            conf.write('      - <<: *zcash-params\n')      
            if coin == "KMD":
                conf.write('      - /home/USERNAME/.komodo:/home/komodian/.komodo\n')
            else:
                conf.write(f'      - /home/USERNAME/.komodo:/home/komodian/.komodo/{coin}\n')
            conf.write('\n')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('No arguments given, exiting.')
    elif sys.argv[1] == 'clis':
        create_clis()
    elif sys.argv[1] == 'confs':
        create_confs()
    elif sys.argv[1] == 'launch':
        create_launch_files()
    elif sys.argv[1] == 'yaml':
        create_compose_yaml()
    else:
        print('Invalid option, must be in ["clis", "confs", "launch"]')

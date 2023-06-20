#!/bin/python3
import string
import secrets
import sys
import os

# Get the list of coins

home = os.path.expanduser('~')

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

def create_clis():
    for coin in coins:
        with open(f"{home}/.komodo/{coin}-cli", 'w') as conf:
            if coin != 'KMD':
                conf.write('#!/bin/bash\n')
                conf.write(f"komodo-cli -ac_name={coin} $@")
        os.chmod(f"{home}/.komodo/{coin}-cli", 0o755)


def generate_rpc_pass(length=24):
    special_chars = "@~-_|():+"
    rpc_chars = string.ascii_letters + string.digits + special_chars
    return "".join(secrets.choice(rpc_chars) for _ in range(length))


def create_confs():
    for coin in coins:
        with open(f"{home}/.komodo/{coin}/{coin}.conf", 'w') as conf:
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


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('No arguments given, exiting.')
    elif sys.argv[1] == 'clis':
        create_clis()
    elif sys.argv[1] == 'confs':
        create_confs()
    else:
        print('Invalid option, must be "clis" or "confs".')
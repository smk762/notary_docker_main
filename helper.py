#!/usr/bin/env python3
import os
import secrets
import string
from based_58 import get_addr_from_pubkey
from const import HOME, SCRIPT_PATH, COINS_DATA, LAUNCH_PARAMS, COINS_DATA, IS_NOTARY, COMMIT_HASHES


def get_coins() -> list:
    '''Get the list of coins'''
    return list(COINS_DATA.keys())

def get_commit_hash(coin):
    if coin in COMMIT_HASHES:
        return COMMIT_HASHES[coin]
    return COMMIT_HASHES["KMD"]

def get_dockerfile(coin):
    dockerfiles = [i for i in os.listdir("docker_files") if i.startswith("Dockerfile")]
    if f"Dockerfile.{coin}" in dockerfiles:
        return f"Dockerfile.{coin}"
    else:
        return f"Dockerfile.KMD"

def generate_rpc_pass(length: int=24) -> str:
    '''Generates a random string for the rpcuser and rpcpass'''
    special_chars = "~.-_"
    rpc_chars = string.ascii_letters + string.digits + special_chars
    return "".join(secrets.choice(rpc_chars) for _ in range(length))


def get_rpc_creds(conf_file: str) -> tuple:
    '''Uses existing rpcuser and rpcpass if they exist,
       otherwise generates new ones'''
    rpcuser = generate_rpc_pass()
    rpcpass = generate_rpc_pass()
    if os.path.exists(conf_file):
        with open(conf_file, 'r') as f:
            lines = f.readlines()
            for line in lines:
                if line.startswith('rpcuser'):
                    rpcuser = line.split('=')[1].strip()
                if line.startswith('rpcpassword'):
                    rpcpass = line.split('=')[1].strip()    
    return (rpcuser, rpcpass)


def get_daemon(coin):
    return COINS_DATA[coin]["daemon"]


def get_launch_params(coin, is_notary=IS_NOTARY):
    launch = get_daemon(coin)
    if coin == 'MCL':
        launch += " -ac_name=MCL -ac_supply=2000000 -ac_cc=2 -addnode=5.189.149.242 -addnode=161.97.146.150 -addnode=149.202.158.145 -addressindex=1 -spentindex=1 -ac_marmara=1 -ac_staked=75 -ac_reward=3000000000 -daemon"
    elif coin == 'ZOMBIE':
        launch += " -ac_name=ZOMBIE -ac_supply=0 -ac_reward=25600000000 -ac_halving=388885 -ac_private=1 -ac_sapling=1 -testnode=1 -addnode=65.21.51.116 -addnode=116.203.120.163 -addnode=168.119.236.239 -addnode=65.109.1.121 -addnode=159.69.125.84 -addnode=159.69.10.44"
    elif is_notary and coin in ["KMD", "KMD_3P"]:
        if coin == 'KMD':
            launch += " -gen -genproclimit=1 -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary=.litecoin/litecoin.conf"
        elif coin == 'KMD_3P':
            launch += " -minrelaytxfee=0.000035 -opretmintxfee=0.004 -notary"
        launch += " -daemon"
    elif coin in LAUNCH_PARAMS:
        launch += f" {LAUNCH_PARAMS[coin]}"
    if coin in ["RICK", "MORTY", "DOC", "MARTY", "ZOMBIE"]:
        launch += f" -gen -genproclimit=1 -pubkey=022d7424c741213a2b9b49aebdaa10e84419e642a8db0a09e359a3d4c850834846" # faucet.komodo.earth pubkey
    else:
        launch += f" -pubkey={get_pubkey(coin)}"
    return launch


def get_cli(coin, container=True) -> str:
    if not container:
        return f"{coin.lower()}-cli"
    elif coin in COINS_DATA:
      return COINS_DATA[coin]["cli"]
    return ""


def is_smartchain(coin: str) -> str:
    return COINS_DATA[coin]["is_smartchain"]


def get_pubkey(coin: str) -> str:
    return COINS_DATA[coin]["pubkey"]


def get_base58(coin: str) -> dict:
    return COINS_DATA[coin]["base58"]


def get_p2pport(coin: str) -> str:
    return COINS_DATA[coin]["p2pport"]


def get_rpcport(coin: str) -> str:
    return COINS_DATA[coin]["rpcport"]


def get_conf(coin, container=True):
    conf = COINS_DATA[coin]["conf"]
    return  f"/home/komodian/{conf}"


def get_data_path(coin, container=True):
    conf_path = get_conf(coin, container)
    return os.path.split(conf_path)[0]


def get_wallet(coin, container=True):
    return f"{get_data_path(coin, container)}/wallet.dat"


def get_debug(coin, container=True):
    return f"{get_data_path(coin, container)}/debug.log"


def get_server(coin):
    return COINS_DATA[coin]["dpow"]["server"]


def get_utxo_value(coin):
    return COINS_DATA[coin]["dpow"]["utxo_value"]


def get_utxo_threshold(coin):
    return COINS_DATA[coin]["dpow"]["min_utxo_count"]


def get_split_count(coin):
    return COINS_DATA[coin]["dpow"]["split_count"]


def get_tx_fee(coin):
    return COINS_DATA[coin]["dpow"]["txfee"]


def get_address(coin: str) -> str:
    pubkey = get_pubkey(coin)
    return get_addr_from_pubkey(pubkey, coin)


def get_data_path(coin, container=True):
    return os.path.split(get_conf(coin, container))[0]


def get_debug_file(coin, container=True) -> str:
    path = get_data_path(coin, container)
    if container:
        path = path.replace(HOME, "/HOME/komodian")
    return f"{path}/debug.log"


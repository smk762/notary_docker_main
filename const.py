
import os
import json
import requests


HOME = os.path.expanduser('~')
SCRIPT_PATH = os.path.realpath(os.path.dirname(__file__))
IS_NOTARY = False
IS_INSIGHT_EXPLORER = True

# Get the list of coins to build & launch. Edit this file to add/remove coins.
DOCKER_COINS = json.load(open(os.path.join(SCRIPT_PATH, "docker_coins.json")))

# Sourced from https://github.com/KomodoPlatform/coins/blob/master/launch/smartchains.json
LAUNCH_PARAMS = json.load(open(os.path.join(SCRIPT_PATH, "smartchains.json")))

# Any additional metadata about a coin (e.g. which dPoW server) can be added maunally in coins_data.json
COINS_DATA = json.load(open(os.path.join(SCRIPT_PATH, "coins_data.json"), "r"))
# Its cleaner if we standarise the ports for each coin with a simple offset
for k, v in COINS_DATA.items():
    p2pport = v["p2pport"]
    rpcport = p2pport + 1
    zmqport = p2pport + 2
    webport = p2pport + 3
    COINS_DATA[k].update({
        "p2pport": p2pport,
        "rpcport": rpcport,
        "zmqport": zmqport,
        "webport": webport
    })
json.dump(COINS_DATA, open(os.path.join(SCRIPT_PATH, "coins_data.json"), "w"), indent=4)
    

# Whitelist of addresses that can send funds. This is used to mitigate spamming.
ADDRESS_WHITELIST = {
    "s6_dragonhound_DEV_main": "RDragoNHdwovvsDLSLMiAEzEArAD3kq6FN",
    "s6_dragonhound_DEV_3p": "RLdmqsXEor84FC8wqDAZbkmJLpgf2nUSkq",
    "s7_dragonhound_DEV_main": "RHi882Amab35uXjqBZjVxgEgmkkMu454KK",
    "s7_dragonhound_DEV_3p": "RHound8PpyhVLfi56dC7MK3ZvvkAmB3bvQ"
}

# Adds a few notaries as peers to the daemons
DAEMON_PEERS = {
    "dragonhound_AR": "15.235.204.174",
    "dragonhound_NA": "209.222.101.247",
    "dragonhound_DEV": "103.195.100.32",
    "dragonhound_EU": "178.159.2.9",
    "gcharang_AR": "148.113.1.52",
    "gcharang_SH": "51.161.209.100",
    "gcharang_DEV": "148.113.8.6",
    "alright_DEV": "144.76.80.75",
    "alright_EU": "65.21.77.109",
    "Marmara1": "89.19.26.211",
    "Marmara2": "89.19.26.212"
}

# Get the latest commit hashes for the dPoW notary daemons
# When this file changes, we need to run `./update`
commit_hashes_url = "https://raw.githubusercontent.com/KomodoPlatform/dPoW/master/doc/daemon_versions.json"
COMMIT_HASHES = requests.get(commit_hashes_url).json()
with open(os.path.join(SCRIPT_PATH, "daemon_versions.json"), "w") as f:
    json.dump(COMMIT_HASHES, f, indent=4)

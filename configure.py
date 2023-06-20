#!/bin/python3
import requests
import os

# Get the list of coins
r = requests.get('https://raw.githubusercontent.com/KomodoPlatform/dPoW/season-seven/iguana/assetchains.json')
coins = r.json()

for i in coins:
    coin = {i['ac_name']}
    with open(f"/home/$USER/.komodo/{coin}-cli", 'w') as conf:
        conf.write('#!/bin/bash\n')
        conf.write(f"komodo-cli -ac_name={coin} $@")
    os.chmod(f"/home/$USER/.komodo/{coin}-cli", 0o755)

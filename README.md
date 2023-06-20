# notary_docker_main

Simple setup for running Main notary node daemons for dPoW.
---
## Requirements

 - [Docker](https://docs.docker.com/engine/install/ubuntu/) / [w/ convenience script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
 - [Docker Compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)
 - Docker linux post install steps: https://docs.docker.com/engine/install/linux-postinstall/ , Configure Docker to start on boot with systemd
 - 100GB+ disk space free
---
## Make Docker respect UFW

**Docker adds iptables rules that will override UFW rules!** 
Make sure to run the steps below to secure the ports used by Docker. See this article for more info: https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/

Open docker config file
```
sudo nano /etc/default/docker
```

Add this line; save and exit.
```
DOCKER_OPTS="--iptables=false"
```

Restart docker
```
sudo systemctl restart docker
```
---
## Setup

1. Clone this repository: `git clone https://github.com/smk762/notary_docker_main`
2. Run `./setup_main.sh` to create the `.env` and `docker-compose.yml` files and build the daemon containers
3. Run `./start_main.sh` to launch all the deamons within the docker containers, and tail their logs
4. Run `./iguana_main.sh` to launch Iguana for the 3P daemons within the docker containers
5. Run `./stop_main.sh` to stop all the deamons

As we will be running multiple instances of the KMD daemon on the server, we will be using a non-standard data folder and ports for the 3P KMD daemon. This is to avoid conflicts with the native KMD daemon running on the host machine for the "main" coins.
There may also some other minor differences with paths and ports used for daemons within the docker containers, so a [modified `m_notary_main`](https://github.com/KomodoPlatform/dPoW/blob/season-seven/iguana/m_notary_main_docker) file is used to launch Iguana.

---
### Some other commands that may come in handy later:
- Run `./add_peers.sh` to help add connections when doing initial sync.
- Run `./start_main.sh <ticker>` to launch a specific deamon within a docker container, and tail it's logs
- Run `./stop_main.sh <ticker>` to stop a specific deamon
- Run `./logs_main.sh <ticker>` to follow the logs for a specific deamon
---

### Updating daemon versions

When there is an update to any daemon repository, we need to update our `docker-compose.yml` file with the updated `COMMIT_HASH` for deamons which need to be rebuilt.
- Run `./update_main.sh` to stop all daemons, update this repo, regenerate the `docker-compose.yml` file, rebuild the docker images, and then restart all daemons.
- Run `./update_main.sh <ticker>` to stop a specific daemon, rebuild its docker image, and then restart the daemon.
- To clear old docker cache, use `docker system prune -a --volumes`. This will mean everything must be rebuilt, but the data folders will remain intact on the host machine.
- To force a rebuild of a specific docker image, use `docker compose build <service> --no-cache`

---
### To use cli commands

For main coins, you can just use the `komodo-cli` binary as you normally would. For example:
```bash
komodo-cli getinfo
komodo-cli -ac_name=DOC getinfo
```

After building the main docker images, the cli binary for `komodod` will be located in the `~/.komodo` folder. Lets create a symbolic link for it:
```bash
# KMD
sudo ln -s /home/${USER}/.komodo/komodo-cli /usr/local/bin/komodo-cli
```

### Optional: Create wrappers and symbolic links for all the other main coins

Though you can just use the `komodo-cli` binary as you normally would, if you prefer to setup a cli wrapper for each coin, follow the steps below (using DOC as an example):

- Open a new file with `nano ~/.komodo/doc-cli`
    ```bash
    #!/bin/bash
    komodo-cli -ac_name=DOC $@
    ```
- Save and exit, then make executable with `chmod +x ~/.komodo/doc-cli`
- Create a symbolic link with `sudo ln -s /home/${USER}/.komodo/doc-cli /usr/local/bin/doc-cli`
- Rinse and repeat for all other smart chains on the main server.

Alternatively, run the `./setup_clis.sh` script **after** installing the daemons to create the wrappers and symbolic links for you.

---
## What might go wrong?

#### Chain needs reindex

If you already have data in the daemon data folders (e.g. from a previous season) then you might encounter some issues like below.
```
mil_1    | : You need to rebuild the database using -reindex-chainstate to change addressindex.
mil_1    | Please restart with -reindex or -reindex-chainstate to recover.
```

To overcome this, you can either delete the data folders and restart the containers, or enter the container to launch the daemons with `reindex` manually.

```
# Enter the container
docker compose run <service> bash

# Launch the daemon with reindex
mild -reindex

# Monitor the daemon logs
tail -f ~/.mil/debug.log (you can also do this from outside the container, as the `.mil` folder is a shared volume)

# Exit the container
exit
```
#### Bind address already in use

If you see the following:
```
Error response from daemon: driver failed programming external connectivity on endpoint notary_docker_main-kmd-1 (b38e98fe0534cf22b41c424be924de0b826835080e21cdf1b557c927295f2304): Error starting userland proxy: listen tcp4 0.0.0.0:7771: bind: address already in use
```

Make sure you are not running any other instances of the daemon on your host machine. Stop the deamons, and then run `docker compose up -d` again.

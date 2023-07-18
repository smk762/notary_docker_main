# notary_docker_main

Simple setup for running Main notary node daemons for dPoW. These are grouped into docker containers, and launched with docker-compose.
There are a few branches to spread the load, each with a branch name like `notary-explorer-group-NUMBER` in this repo, with an accompanying branch with the same name in https://github.com/smk762/komodo-install-explorer

The chains in each group are as follows:

Group 1:
- DOC
- MARTY
- PIRATE
- NINJA


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

1. Clone this repository: `git clone https://github.com/smk762/notary_docker_main -b notary-explorer-group-one --recurse-submodule` 
2. Run `./setup` to install the zcash-params and pip dependencies.
3. Run `./update` to:
    - Update the insight-explorer submodule
    - Generate daemon config files
    - Create and link cli wrappers
    - Create a `docker-compose.yml` file for the daemon and explorer containers
    - Build and start the containers.

The following commands can be used to manage the docker containers:
- Run `./start` to launch all the deamons within the docker containers, and tail their logs
- Run `./stop` to stop all the deamons and explorers
- Run `./logs` to follow the container logs


### Updating daemon versions

When there is an update to any daemon repository, we need to update our `docker-compose.yml` file with the updated `COMMIT_HASH` for deamons which need to be rebuilt.
- Run `./update` to stop all daemons, update this repo, regenerate the `docker-compose.yml` file, rebuild the docker images, and then restart all daemons.
- Run `./update <ticker>` to stop a specific daemon, rebuild its docker image, and then restart the daemon.
- To clear old docker cache, use `./purge`. This will mean everything must be rebuilt, but the data folders will remain intact on the host machine. Do this while your containers are running unless you want to rebuild them all.
- To force a rebuild of a specific docker image, use `docker compose build <service> --no-cache`

---
### To use cli commands

Use the cli wrappers created during setup. For example:
```bash
doc-cli getinfo
marty-cli getbalance
```
These files will be located in `~/cli-wrappers` and added to PATH during setup.

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



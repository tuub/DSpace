# Docker integration for DSpace/DepositOnce

## Prerequisites

Follow the official guide on docker.io to install Docker und docker-compose: https://docs.docker.com/install/

Or, on Ubuntu 16.04 do this, if you know what you're doing:

### Install Docker and docker-compose
```
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get update
sudo apt-get install docker-ce

sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
And give yourself Docker access rights:
```
usermod -a -G docker $(whoami)
```
Log out and Login again.

## Set up

- Create a copy of `docker-compose.yml.dist` -> `docker-compose.yml`
- In `docker-compose.yml` change the user id number to yours (default: 1000):
    ```
    image: depositonce-USERID
    user: "USERID"
    ```
- Tomcat defaults to port 8080. Change this to your needs in `docker-compose.yml` in service "depositonce". Change the part before the ":" on the line after "ports:".
- In DSpaces' `local.cfg` set the postgres host and port to `db:5432` (located in `docker-compose.yml`)
- In `local.cfg` change `solr.server = http://127.0.0.1:8180/solr` and set the port of your Tomcat there (default: 8080)
- If you want to catch all outgoing mails with Mailhog (relevant for development/debugging only): 
    - In `local.cfg` set `mail.server = mail` and `mail.server.port = 1025`
    - In `docker-compose.yml` uncomment mail service at the end of the file
    - You can access Mailhog with yoour web browser on http://localhost:8025
- Copy Tomcat config to the tomcat-conf docker volume and modify it if needed:
    ```
    cp -r docker/conf/tomcat/* docker/volumes/tomcat-conf/
    ```
- Run `docker/prepare.sh` to create some folders and to set permissions

## Run

- Run `docker/build.sh` to build DepositOnce
    - See `docker/build.sh -h` for all options
- Run `docker/install.sh` to install DepositOnce
    - See `docker/install.sh -h` for all options


- Run `docker-compose up -d` to run DepositOnce
- Run `docker-compose down` to stop DepositOnce

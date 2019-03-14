#!/usr/bin/env bash

# Install DepositOnce using Docker

set -e # break on error

DEPONCE_SERVICE="depositonce"

function usage {
    echo "Usage: $0 [-u]"
    echo "  -u     Do update clean_backups"
    echo "Calling this without options will install with fresh_install."
}

# CLI options
ANT_TARGET="fresh_install"
while getopts u opt; do
    case $opt in
        u)
            ANT_TARGET="update clean_backups"
        ;;
        h|*)
            usage
            exit 1
        ;;
    esac
done

set -x # show commands

# Fresh install DSpace using Docker

#docker-compose up -d

docker-compose run --rm -T "$DEPONCE_SERVICE" bash -c "
    cd /var/dspace-src/dspace/target/dspace-installer
    ant $ANT_TARGET"
docker-compose run --rm -T "$DEPONCE_SERVICE" bash -c "
    rm -rf /usr/local/tomcat/webapps/*
    ln -sf /var/dspace/webapps/* /usr/local/tomcat/webapps/
    mv /usr/local/tomcat/webapps/jspui /usr/local/tomcat/webapps/ROOT"

#docker-compose restart "$DEPONCE_SERVICE"

#[dspace]/bin/dspace create-administrator

exit 0

#!/usr/bin/env bash

# Prepare workspace for running DepositOnce using Docker

set -x

BASEDIR=$(pwd)

if [ "$DATA_DIR" == "" ]; then
    DATA_DIR=$(pwd)
fi
if [ "$DSPACE_DIR" == "" ]; then
    DSPACE_DIR="$DATA_DIR/docker/volumes/dspace"
fi
if [ "$DSPACEDATA_DIR" == "" ]; then
    DSPACEDATA_DIR="$DATA_DIR/docker/volumes/dspace-data"
fi
if [ "$DB_DIR" == "" ]; then
    DB_DIR="$DATA_DIR/docker/volumes/db-data"
fi
if [ "$WEBAPPS_DIR" == "" ]; then
    WEBAPPS_DIR="$DATA_DIR/docker/volumes/tomcat-webapps"
fi
if [ "$TOMCATCONF_DIR" == "" ]; then
    TOMCATCONF_DIR="$DATA_DIR/docker/volumes/tomcat-conf"
fi
if [ "$MAVEN_CACHE" == "" ]; then
    MAVEN_CACHE="$DATA_DIR/docker/volumes/maven-cache"
fi

set -e

# create docker volumes to keep correct permissions
mkdir -p "$DB_DIR"
mkdir -p "$DSPACE_DIR"
mkdir -p "$DSPACEDATA_DIR"
mkdir -p "$MAVEN_CACHE"
mkdir -p "$WEBAPPS_DIR"
mkdir -p "$TOMCATCONF_DIR"

OWNUSER=$(whoami)

# set ACLs to keep access to docker volumes from the host user
setfacl -R -m u:$OWNUSER:rwX $BASEDIR $DSPACE_DIR $DSPACEDATA_DIR $WEBAPPS_DIR $TOMCATCONF_DIR $MAVEN_CACHE
setfacl -dR -m u:$OWNUSER:rwX $BASEDIR $DSPACE_DIR $DSPACEDATA_DIR $WEBAPPS_DIR $TOMCATCONF_DIR $MAVEN_CACHE

# activate pgcrypto
#docker-compose up -d
#docker-compose exec db psql --username=postgres dspace -c "CREATE EXTENSION pgcrypto;"

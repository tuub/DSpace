#!/usr/bin/env bash

# Build DepositOnce using Docker

set -e # break on error

# Environment variables

DEPONCE_IMAGE="depositonce"

BASEDIR=$(pwd)

USERID=$(id -u)

if [ "$DATA_DIR" == "" ]; then
    DATA_DIR=$(pwd)
fi
if [ "$DSPACE_DIR" == "" ]; then
    DSPACE_DIR="$DATA_DIR/docker/volumes/dspace"
fi
if [ "$MAVEN_CACHE" == "" ]; then
    MAVEN_CACHE="$DATA_DIR/docker/volumes/maven-cache"
fi

BASECMD="mvn -B -Dmaven.repo.local=/tmp/.m2/repository"

# default command
CMD="$BASECMD clean package -P !dspace-lni,!dspace-xmlui,!dspace-rdf,!dspace-sword,!dspace-swordv2,!dspace-xmlui-mirage2"

function usage {
    echo "Usage: $0 [-t|-c]"
    echo "  -t     Run tests"
    echo "  -c     Clean project"
    echo "Calling this without options will build only."
    echo
    echo "Environment variables:"
    echo "  DATA_DIR:     DSpace data dir"
    echo "  DSPACE_DIR:   DSpace bin dir"
    echo "  MAVEN_CACHE:  Maven build repo cache"
}

# CLI options
TESTS=""
while getopts tc opt; do
    case $opt in
        t)
            CMD="$CMD -Dmaven.test.skip=false"
            RUNUSER="--user $USERID"
        ;;
        c)
            CMD="$BASECMD clean"
        ;;
        h|*)
            usage
            exit 1
        ;;
    esac
done

set -x # show commands

# Test DSpace using Docker

docker build -t "$DEPONCE_IMAGE-$USERID" --build-arg userid=$USERID ./docker/images/dspace-ubuntu/
#docker run -t --rm --user "$RUNUSER" \
docker run -t --rm $RUNUSER \
    -w  /var/dspace-src \
    -v "$BASEDIR:/var/dspace-src" \
    -v "$DSPACE_DIR:/var/dspace" \
    -v "$MAVEN_CACHE:/tmp/.m2/repository" \
    "$DEPONCE_IMAGE-$USERID" \
    $CMD

exit 0

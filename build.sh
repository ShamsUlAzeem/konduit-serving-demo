#!/usr/bin/env bash
set -e

CHIP=$(echo $1 | awk '{ print toupper($0)}')
if [[ -z "$CHIP" ]]
then
      CHIP=CPU
fi

if [[ $2 == --rebuild-jar ]]
then
    echo "Removing pre-built konduit.jar"
    if [[ -f "konduit.jar" ]]
    then
        rm konduit.jar
    fi
fi

if [[ "$CHIP" != "CPU" && "$CHIP" != "GPU" ]]
then
    echo "Selected CHIP should be one of [CPU, GPU]"
    echo "Usage: bash build.sh CPU"
    echo "Usage with rebuilding JAR file: bash build.sh CPU --rebuild-jar"
    exit 1
fi


if [[ ! -f "konduit.jar" ]]
then
    echo "Building a konduit-serving distributable JAR file..."
    if [[ ! -d "konduit-serving" ]]
    then
        echo "konduit-serving repo doesn't exist in the root folder. Cloning the konduit-serving repo..."
        git clone https://github.com/konduitAI/konduit-serving.git
    fi

    echo "Selecting CHIP=$CHIP"

    cd konduit-serving
    echo "Refreshing codebase"
    git stash
    git fetch 
    git checkout sa/fixing-build-command
    git pull

    echo "Building $CHIP version of konduit-serving..."

    if [[ "$CHIP" == "CPU" ]]
    then
        BUILD_PROFILES=-Ppython,uberjar
    else
        BUILD_PROFILES=-Ppython,uberjar,gpu,intel,cuda-redist
    fi 

    mvn clean install -Dmaven.test.skip=true -Denforcer.skip=true -Djavacpp.platform=linux-x86_64 $BUILD_PROFILES -Ddevice=$CHIP
    mv konduit-serving-uberjar/target/konduit-serving-uberjar-0.1.0-SNAPSHOT-custom-linux-x86_64-$CHIP.jar ../konduit.jar
    cd ..
else
    echo "Pre-build konduit-serving distributable JAR file already exists. Continuing with docker build..."
fi

rm -rf compose/data-grafana/png/
docker build --tag konduitai/demo:1.1 .

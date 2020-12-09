#!/usr/bin/env bash
if [[ ! -f "konduit.jar" ]]
then
    echo "konduit.jar not found..."
    if [[ -d "konduit-serving" ]]
    then
        echo "konduit-serving repo doesn't exist in the root folder. Cloning the konduit-serving repo..."
        git clone https://github.com/konduitAI/konduit-serving.git
    fi

    cd konduit-serving
    echo "Refreshing codebase"
    git stash
    git fetch
    git pull 
    
    git checkout sa/fixing-build-command

    echo "Building CPU version of konduit-serving..."
    mvn clean install -Dmaven.test.skip=true -Denforcer.skip=true -Djavacpp.platform=linux-x86_64 -Ppython,uberjar -Ddevice=cpu
    mv konduit-serving-uberjar/target/konduit-serving-uberjar-all-linux-x86_64-cpu ../konduit.jar
    cd ..
fi

rm -rf compose/data-grafana/png/
docker build --tag konduitai/demo:1.1 .

:; set -o errexit
:; function goto() { return $?; }

IF NOT EXIST "konduit.jar" (
    echo "konduit.jar not found..."
    IF NOT EXIST "konduit-serving\" (
        echo "konduit-serving repo doesn't exist in the root folder. Cloning the konduit-serving repo..."
        git clone https://github.com/konduitAI/konduit-serving.git || goto :error
    )

    cd konduit-serving || goto :error
    echo "Refreshing codebase"
    git stash || goto :error
    git fetch || goto :error
    git checkout sa/fixing-build-command || goto :error
    git pull || goto :error

    echo "Building CPU version of konduit-serving..."
    mvn clean install -Dmaven.test.skip=true -Denforcer.skip=true -Djavacpp.platform=linux-x86_64 -Ppython,uberjar -Ddevice=cpu || goto :error
    move konduit-serving-uberjar\target\konduit-serving-uberjar-0.1.0-SNAPSHOT-custom-linux-x86_64-cpu.jar ..\konduit.jar || goto :error
    cd ..
)

RMDIR /Q/S compose\data-grafana\png\ || goto :error
docker build --tag konduitai/demo:1.1 .

:; exit 0
exit /b 0

:error
exit /b %errorlevel%
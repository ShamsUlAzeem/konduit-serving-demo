# Build and Run konduit-serving-demo
Following are the commands for building and running konduit-serving-demo on different platforms: 

## For Linux and MacOS
- Build command: `bash build.sh`
- Run command: `bash run.sh`

## For Windows
- Build command: `build.bat`
- Run command: `run.bat`

# Visiting the Jupyter Lab URL
After successful run, you can visit the URL mentioned in the docker-compose logs, shown similar to the following line
```shell
konduit-demo_1  | [I 00:00:34.399 LabApp]  or http://127.0.0.1:8889/?token=d8feedd7844a6f83572eeca22602b957a9fd7111b93e6a03
```

In the above case, you'll have to visit the URL http://127.0.0.1:8889/?token=d8feedd7844a6f83572eeca22602b957a9fd7111b93e6a03 to start using konduit-serving on Jupyter Lab. 

!! | Tokens will be different for each run of the demo so the URL will be different in each case
:---: | :---
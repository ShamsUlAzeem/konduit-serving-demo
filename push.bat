docker tag konduitai/demo:1.1 docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:metrics

docker push docker.pkg.github.com/konduitai/konduit-serving-demos/quick-start:metrics

docker tag konduitai/demo:1.1 konduit/konduit-serving-demo:metrics

docker push konduit/konduit-serving-demo:metrics
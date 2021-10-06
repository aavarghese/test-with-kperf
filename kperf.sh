export VERSION=0.3
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/aslom}/kperf:${VERSION}

docker run  --env-file env.list $IMAGE_NAME /kperf$@



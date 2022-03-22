export VERSION=0.4
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/avarghese23}/kperf:${VERSION}

docker run  --env-file env.list $IMAGE_NAME /kperf $@



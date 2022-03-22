export SETUP_ID=local-http-baseline
export LOCAL_RECEIVER_PORT=8001
export TARGET_URL=http://localhost:8001

#KPERF=${KPERF:=./kperf.sh}

export VERSION=0.4
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/avarghese23}/kperf:${VERSION}



echo "Launching kperf $KPERF receiver locally"
#sleep 50 &
#../test-with-kperf/kperf.sh eventing receiver &
#$KPERF eventing receiver &
docker run  --env-file env.list -p 8001:8001 $IMAGE_NAME /kperf eventing receiver
export LOCAL_RECEIVER_PID=$!
export LOCAL_RECEIVER_PGID=$(ps opgid= "$LOCAL_RECEIVER_PID")
echo "Launched local process in background with PID $LOCAL_RECEIVER_PID  PGID $LOCAL_RECEIVER_PGID"  

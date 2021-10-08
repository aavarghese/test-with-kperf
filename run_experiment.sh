#!/bin/bash

set -e # exit on error

export VERSION=0.3
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/aslom}/kperf:${VERSION}

# https://stackoverflow.com/questions/4381618/exit-a-script-on-error/4382179
f () {
    errorCode=$? # save the exit code as the first thing done in the trap function
    echo "error $errorCode"
    echo "the command executing at the time of the error was"
    echo "$BASH_COMMAND"
    echo "on line ${BASH_LINENO[0]}"
    exit $errorCode  # or use some other value or do return instead
}
trap f ERR

# check required env vars EXPERIMENT_ID, SETUP_ID, WORKLOAD_ID
if [[ -z "${EXPERIMENT_ID}" ]]; then
  echo "ERROR: environment variable EXPERIMENT_ID must be set."  1>&exit 1
fi

echo "===================================================="
echo "Starting experiment EXPERIMENT_ID=$EXPERIMENT_ID"

if [[ -z "${SETUP_ID}" ]]; then
  echo "ERROR: environment variable SETUP_ID must be set."  1>&exit 1
fi
SETUP_DIR=${SETUP_DIR:=setup}
SETUP_FILE="${SETUP_DIR}/${SETUP_ID}.sh"
if [ ! -f $SETUP_FILE ]; then
  echo "ERROR: could find setup for $SETUP_FILE"  1>&exit 1
fi
if [[ -z "${WORKLOAD_ID}" ]]; then
  echo "ERROR: environment variable WORKLOAD_ID must be set."  1>&exit 1
fi

WORKLOAD_DIR=${WORKLOAD_DIR:=workload}
WORKLOAD_FILE="${WORKLOAD_DIR}/${WORKLOAD_ID}.sh"
if [ ! -f $WORKLOAD_FILE ]; then
  echo "ERROR: could find workload for $WORKLOAD_FILE"  1>&exit 1
fi
echo "Using setup SETUP_ID=$SETUP_ID loaded from $SETUP_FILE"
source "$SETUP_FILE"
echo "Using workload WORKLOAD_ID=$WORKLOAD_ID loaded from $WORKLOAD_FILE"
source "$WORKLOAD_FILE"


# --skip-cleanup

# prepare
# LOCAL_RECEIVER_PID=""
# #echo "LOCAL_RECEIVER_PORT=$LOCAL_RECEIVER_PORT"
# # if local-setup run with $PID
# if [[ -z "${LOCAL_RECEIVER_PORT}" ]]; then
#   echo "Preparing setup $SETUP_ID"  1>&exit 1
# else
#   echo "Launching kperf prepare locally"
#   sleep 50 &
#   LOCAL_RECEIVER_PID=$!
#   echo "Launched local process in background with PID $LOCAL_RECEIVER_PID"  
# fi

# run remote job or local process
# $KPERF driver &

#cat ../kperf/config/driver-job.yaml | envsubst 

echo "driver EXPERIMENT_ID=$EXPERIMENT_ID SETUP_ID=$SETUP_ID WORKLOAD_ID=$WORKLOAD_ID TARGET_URL=$TARGET_URL KAFKA_BOOTSTRAP_SERVERS=$KAFKA_BOOTSTRAP_SERVERS "
# run in background
(cat ../kperf/config/driver-job.yaml | envsubst | kubectl apply -f -)&


# measure
echo "measure until no more metrics"
#./kperf.sh eventing measure 
docker run --network="host" --env-file env.list -p 8001:8001 $IMAGE_NAME /kperf eventing measure 
#sleep 1

CLEANUP_FILE=${SETUP_FILE%.sh}_clean.sh
echo "CLEANUP_FILE=$CLEANUP_FILE"
if [ -f $CLEANUP_FILE ]; then
  echo "Running cleanup $CLEANUP_FILE"
  source $CLEANUP_FILE
fi  
echo "===================================================="

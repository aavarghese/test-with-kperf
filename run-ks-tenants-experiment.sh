#!/bin/bash

set -e # exit on error

#set -o xtrace
#set -o verbose

SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 
source ./experiment-library.sh
trap f ERR

switchToO5
jobsCleanup

for TENANT_ID in $(seq 5)
do
    export EXPERIMENT_ID=mar22a
    export SETUP_ID=o5
    export WORKLOAD_ID=tenant${TENANT_ID}
    export CONCURRENT=10
    strimzi
    export KAFKA_TOPIC=topic100-${TENANT_ID}
    if [ $TENANT_ID = "1" ]; then
        #echo "first tenant"
        export START=100
        export DURATION=100
        #echo "first tenant run for $DURATION"
    else
        export START=100
        export DURATION=30
        #SLEEP_TIME=2
        #echo "tenant $TENANT_ID sleep $SLEEP_TIME seconds before running"
        #sleep $SLEEP_TIME
    fi
    if [ $TENANT_ID = "2" ]; then
        #SLEEP_TIME=30
        #echo "after starting tenant $TENANT_ID sleep $SLEEP_TIME seconds before running next tenant"
        #sleep $SLEEP_TIME
    fi
    export TEST_DURATION=$DURATION
    echo "start tenant $TENANT_ID to run $DURATION seconds for EXPERIMENT_ID=$EXPERIMENT_ID SETUP_ID=$SETUP_ID WORKLOAD_ID=$WORKLOAD_ID TARGET_URL=$TARGET_URL KAFKA_BOOTSTRAP_SERVERS=$KAFKA_BOOTSTRAP_SERVERS KAFKA_TOPIC=$KAFKA_TOPIC"
    (cat ./config/driver-job.yaml | envsubst | kubectl apply -f -)&
done

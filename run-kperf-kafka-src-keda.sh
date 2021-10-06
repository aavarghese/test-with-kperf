#!/bin/bash
set -e # exit on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export EXPERIMENT_ID=oct6c

#for setup in http strimzi-kafka1-topic10
#for setup in alek-ocp-http
#for setup in alek-ocp-kss-topic10 alek-ocp-kss-topic100 alek-ocp-kss-topic1000
#for setup in alek-ocp-kss-topic100 alek-ocp-kss-topic1000
for setup in alek-ocp-kss-topic10
do
    export SETUP_ID=$setup
    #for workload in 2x2x2 10x10x10 100x100x10
    for workload in 100x100x10
    #for workload in 2x2x2 
    do
        export WORKLOAD_ID=$workload
        #echo "EXPERIMENT_ID=$EXPERIMENT_ID SETUP_ID=$SETUP_ID WORKLOAD_ID=$WORKLOAD_ID"
        ./run_experiment.sh
    done
done

#!/bin/bash

set -e # exit on error

#set -o xtrace
#set -o verbose

SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 
source ./experiment-library.sh
trap f ERR

switchToO5

deployReceiverHttpOnly

#kafkaSrc100
for TENANT_ID in $(seq 10)
do
    createKafkaSrc 100 $TENANT_ID
done

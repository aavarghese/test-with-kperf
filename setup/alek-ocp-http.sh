SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 
#"$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export SETUP_ID=alek-ocp-http-baseline
export TARGET_URL=http://kperf-eventing-receiver

export VERSION=0.3
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/aslom}/kperf:${VERSION}
#export IMAGE_NAME=quay.io/aslom/kperf

echo IMAGE_NAME=$IMAGE_NAME


unset KAFKA_BOOTSTRAP_SERVERS
unset KAFKA_TOPIC
unset KAFKA_GROUP
unset REDIS_ADDRESS

./setup/jobs-cleanup.sh
./setup/delete-kafkasources.sh

cat ../kperf/config/receiver.yaml | envsubst

cat ../kperf/config/receiver.yaml | envsubst | kubectl apply -f -

echo "Wait for kperf receiver to get ready"
kubectl wait deployment/kperf-eventing-receiver --for=condition=Available --timeout=300s

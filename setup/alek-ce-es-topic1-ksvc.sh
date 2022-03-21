SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 

export SETUP_ID=alek-ce-es-t10
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

#cat ../kperf/config/receiver.yaml | envsubst

source ./setup/http-only.sh
#export SLEEP_SECONDS=0
echo "SLEEP_SECONDS=$SLEEP_SECONDS"
cat ../kperf/config/receiver.yaml | envsubst | kubectl apply -f -

echo "Waiting for kperf receiver to get ready"
kubectl wait deployment/kperf-eventing-receiver --for=condition=Available --timeout=300s

echo "Waiting for kperf cloudevents-forwarder-ksvc to get ready"
cat ./setup/cloudevents-forwarder-ksvc.yaml | envsubst | kubectl apply -f -

echo "Waiting for kperf cloudevents-forwarder-ksvc to get ready"
kubectl wait ksvc/cloudevents-forwarder-ksvc --for=condition=Ready --timeout=300s

echo "Establishing tunnel to namespace where kperf deployment is running "
pkill kubectl port-forward deployment/kperf-eventing-receiver 8001:8001 || true
kubectl port-forward deployment/kperf-eventing-receiver 8001:8001&

kubectl apply -f setup/kafka-source-es10-ksvc.yaml
echo "Waiting for Kafka source to get ready"
kubectl wait kafkasources.sources.knative.dev/kafka-es10 --for=condition=Ready --timeout=300s

source ./setup/es.sh
export KAFKA_TOPIC=e2et10


SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 

export SETUP_ID=alek-ocp-kss-topic100
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

kubectl apply -f setup/kafka-source100.yaml
echo "Wait for Kafka source to get ready"
kubectl wait kafkasources.sources.knative.dev/kafka-src100 --for=condition=Ready --timeout=300s


#cat ../kperf/config/receiver.yaml | envsubst

cat ../kperf/config/receiver.yaml | envsubst | kubectl apply -f -

echo "Wait for kperf receiver to get ready"
kubectl wait deployment/kperf-eventing-receiver --for=condition=Available --timeout=300s

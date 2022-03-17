SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 

export SETUP_ID=alek-ocp-kss-topic10
export TARGET_URL=http://kperf-eventing-receiver

export VERSION=0.4
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/avarghese23}/kperf:${VERSION}

echo IMAGE_NAME=$IMAGE_NAME

unset KAFKA_BOOTSTRAP_SERVERS
unset KAFKA_TOPIC
unset KAFKA_GROUP
unset REDIS_ADDRESS

./setup/jobs-cleanup.sh
./setup/delete-kafkasources.sh

#cat ../kperf/config/receiver.yaml | envsubst

source ./setup/http-only.sh
export SLEEP_SECONDS=0
cat ./config/receiver.yaml | envsubst | kubectl apply -f -

echo "Wait for kperf receiver to get ready"
kubectl wait deployment/kperf-eventing-receiver --for=condition=Available --timeout=300s

echo "Establish tunnel to namespace where kperf deployment is running "
#pkill kubectl port-forward deployment/kperf-eventing-receiver 8001:8001
kubectl port-forward deployment/kperf-eventing-receiver 8001:8001&

kubectl apply -f setup/kafka-source10.yaml
echo "Wait for Kafka source to get ready"
kubectl wait kafkasources.sources.knative.dev/kafka-src10 --for=condition=Ready --timeout=300s

#echo "Sleeping for 20s to give adapter pods enough time to be ready"
#sleep 20s #Buffer time for adapter pods to come up

source ./setup/strimzi.sh
export KAFKA_TOPIC=topic10

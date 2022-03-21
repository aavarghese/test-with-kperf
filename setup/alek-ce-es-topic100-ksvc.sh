SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 

export SETUP_ID=alek-ce-es-topic100
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

if [[ -z "${KEEP_SOURCE}" ]]; then
  ./setup/delete-kafkasources.sh
else 
  echo "Skipping deleting kafka soures." 
fi

#cat ../kperf/config/receiver.yaml | envsubst

echo "Deploying kperf receiver"
source ./setup/http-only.sh
#export SLEEP_SECONDS=0
echo "SLEEP_SECONDS=$SLEEP_SECONDS"
cat ../kperf/config/receiver.yaml | envsubst | kubectl apply -f -

echo "Waiting for kperf receiver to get ready"
kubectl wait deployment/kperf-eventing-receiver --for=condition=Available --timeout=300s

while true; 
do 
  REPLICAS="$(kubectl get deployment kperf-eventing-receiver -o=jsonpath='{.status.readyReplicas}')"
  echo "Waiting for kperf receiver deployment to get one replica ready so far REPLICAS=$REPLICAS"
  if [ "$REPLICAS" = "1"  ] ; then
    break 
  fi
  sleep 1; 
done

#cat ./setup/cloudevents-forwarder-ksvc.yaml | envsubst | kubectl apply -f -
echo "Deploying kperf cloudevents-forwarder-ksvc to get ready"
cat ./setup/cloudevents-forwarder-ksvc-no-sdk.yaml | envsubst | kubectl apply -f -

echo "Waiting for kperf cloudevents-forwarder-ksvc to get ready"
kubectl wait ksvc/cloudevents-forwarder-ksvc --for=condition=Ready --timeout=300s

echo "Establishing tunnel to namespace where kperf deployment is running "
pkill kubectl port-forward deployment/kperf-eventing-receiver 8001:8001 || true
kubectl port-forward deployment/kperf-eventing-receiver 8001:8001&

if [[ -z "${KEEP_SOURCE}" ]]; then
    kubectl apply -f setup/kafka-source-es100-ksvc.yaml
    echo "Waiting for Kafka source to get ready"
    kubectl wait kafkasources.sources.knative.dev/kafka-es100 --for=condition=Ready --timeout=300s
else 
  echo "Skipping deploying kafka soures." 
fi


source ./setup/es.sh
export KAFKA_TOPIC=e2et100

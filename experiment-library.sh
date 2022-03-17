export VERSION=0.4
export IMAGE_NAME=${DOCKER_REGISTRY:-docker.io/aslom}/kperf:${VERSION}
echo IMAGE_NAME=$IMAGE_NAME
export REPLICAS=1
export SLEEP_SECONDS=0

# https://stackoverflow.com/questions/4381618/exit-a-script-on-error/4382179
f () {
    errorCode=$? # save the exit code as the first thing done in the trap function
    echo "error $errorCode"
    echo "the command executing at the time of the error was"
    echo "$BASH_COMMAND"
    echo "on line ${BASH_LINENO[0]}"
    exit $errorCode  # or use some other value or do return instead
}

switchToO5 () {
    echo "Switching context"
    kubectx kperf7/c114-e-us-south-containers-cloud-ibm-com:30501/IAM#aslom@us.ibm.com
    echo "Switching namespace"
    kubens kperf7
}


httpOnly () {
    # http receiver only
    unset KAFKA_BOOTSTRAP_SERVERS
    unset REDIS_ADDRESS
    unset HTTP_PORT
    # no Kafka
    unset KAFKA_BOOTSTRAP_SERVERS
    unset KAFKA_TOPIC
    unset KAFKA_GROUP
    unset KAFKA_NET_TLS_ENABLE
    unset KAFKA_NET_SASL_ENABLE
    unset KAFKA_NET_SASL_USER
    unset KAFKA_NET_SASL_PASSWORD
}

deployReceiverHttpOnly () {
    echo "Deploying kperf receiver"
    #source ./setup/http-only.sh
    httpOnly
    deployReceiver
}

deployReceiverStrimziEnabled () {
    if [[ -z "${KAFKA_TOPIC}" ]]; then
        echo "ERROR: environment variable SETUP_ID must be set."  1>&exit 1
    fi
    echo "Deploying kperf receiver consuming Strimzi Kafka topic $KAFKA_TOPIC"
    strimzi
    deployReceiver
}

deployReceiver () {
    #export SLEEP_SECONDS=0
    echo "SLEEP_SECONDS=$SLEEP_SECONDS"
    cat ../kperf/config/receiver.yaml | envsubst | kubectl apply -f -

    echo "Waiting for kperf receiver deployment to get available"
    kubectl wait deployment/kperf-eventing-receiver --for=condition=Available --timeout=300s

    echo "Establishing tunnel to namespace where kperf deployment is running "
    pkill kubectl port-forward deployment/kperf-eventing-receiver 8001:8001 || true
    kubectl port-forward deployment/kperf-eventing-receiver 8001:8001&
}

kafkaSrc100 () {
    kubectl apply -f ../test-with-kperf/setup/kafka-source100.yaml
    echo "Waiting for Kafka source to get ready"
    kubectl wait kafkasources.sources.knative.dev/kafka-src100 --for=condition=Ready --timeout=300s
    export KAFKA_TOPIC=topic100
    echo "Deployed Kafka source for $KAFKA_TOPIC"
}

createKafkaSrc () {
    PARTITIONS=$1
    TENANT_ID=$2
    export TOPIC_NAME=topic${PARTITIONS}-$TENANT_ID
    export SOURCE_NAME=kafka-src${PARTITIONS}-$TENANT_ID
    export GROUP_NAME=knative-group${PARTITIONS}-$TENANT_ID
    cat ../test-with-kperf/setup/kafka-src-name.yaml | envsubst | kubectl apply -f -
    echo "Waiting for Kafka source to get ready"
    kubectl wait kafkasources.sources.knative.dev/${SOURCE_NAME} --for=condition=Ready --timeout=300s
    echo "Deployed Kafka source $SOURCE_NAME for Kafka topic $TOPIC_NAME"
}

createStrimziTopic () {
    PARTITIONS=$1
    TENANT_ID=$2
    export TOPIC_NAME=topic${PARTITIONS}-$TENANT_ID
    export TOPIC_PARITIONS=$PARTITIONS
    cat ../test-with-kperf/setup/strimzi-topic-name.yaml | envsubst | kubectl apply -f -
}

strimzi () {
    if [[ -z "${SETUP_ID}" ]]; then
        echo "ERROR: environment variable SETUP_ID must be set."  1>&exit 1
    fi
    export KAFKA_GROUP=${SETUP_ID}-receiver
    export TARGET_URL=kafka:/
    export KAFKA_BOOTSTRAP_SERVERS=my-cluster-kafka-bootstrap.kafka:9092
    export KAFKA_NET_TLS_ENABLE=false
    export KAFKA_NET_SASL_ENABLE=false
    export KAFKA_NET_SASL_USER=""
    export KAFKA_NET_SASL_PASSWORD=""
}

deleteKafkaSources () {
    echo "Deleting Kafka sources"
    kubectl get kafkasources.sources.knative.dev --no-headers=true | awk '{print $1}' | xargs kubectl delete kafkasources.sources.knative.dev 
}

jobsCleanup () {
    if [[ -z "${CODE_ENGINE}" ]]; then
        echo "Deleting kubernetes jobs"
        kubectl get jobs --no-headers=true | awk '{print $1}' | xargs  kubectl delete jobs
    else 
        echo "Running with Code Engine job"
    fi
}
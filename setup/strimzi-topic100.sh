SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" ) 
#"$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export KAFKA_BOOTSTRAP_SERVERS=my-cluster-kafka-bootstrap.kafka:9092
export KAFKA_TOPIC=topic100
export KAFKA_GROUP=baseline-kafka100

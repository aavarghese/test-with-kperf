# Instructions to run kperf test with Knative Eventing 

Make sure kperf project is in ../kperf directry or modify kper.sh

Use default namespace or switch Kubernetes context to namespace used for testing, for exmple:

```
kubens kperfns
```

Then run experiment

```
export EXPERIMENT_ID=Jul7
export SETUP_ID=local-http-baseline
export WORKLOAD_ID=2x2x2

./run_experiment.sh
```



## Setup for testing with Strimzi 

Install Strimzi in your cluster

Create kafka namespace

```
k create ns kafka
```

Create Kafka cluster in kafka namespace

Check cluster is erunning

```
kubectl get pod -n kafka 
```

Create test topics

```
kubectl apply -f setup/strimzi-topic1.yaml
kubectl apply -f setup/strimzi-topic10.yaml
kubectl apply -f setup/strimzi-topic100.yaml
kubectl apply -f setup/strimzi-topic1000.yaml
```

# list topics

```
kubectl -n kafka exec -it my-cluster-kafka-0 -c kafka -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list
```

Check topics were created with partitions, for example:

```
kubectl -n kafka exec -it my-cluster-kafka-0 -c kafka -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --describe --topic topic100
```

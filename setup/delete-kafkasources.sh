echo "Deleting Kafka sources"
kubectl get kafkasources.sources.knative.dev --no-headers=true | awk '{print $1}' | xargs kubectl delete kafkasources.sources.knative.dev 

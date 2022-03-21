if [[ -z "${CODE_ENGINE}" ]]; then
    echo "Deleting kubernetes jobs"
    kubectl get jobs --no-headers=true | awk '{print $1}' | xargs  kubectl delete jobs
else 
    echo "Running with Code Engine job"
fi

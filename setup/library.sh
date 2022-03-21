jobs_cleanup()
{
    kubectl get jobs --no-headers=true | awk '{print $1}' | xargs  kubectl delete jobs
}

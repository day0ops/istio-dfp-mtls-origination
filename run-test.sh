#!/usr/bin/env bash

SCRIPT_NAME="`basename $0`"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test_endpoint_url="mtlsapi.aspnet4you.com/pets"
namespace=curl
deployment_name=curl-client
container_name=curl-client

printf "\n\n%s\n\n" "------> First test run (client -> http -> mesh mTLS -> egress gw -> mTLS origination -> $test_endpoint_url) <------"

kubectl exec -it --namespace=$namespace deploy/$deployment_name -c $container_name -- \
    sh -c "curl -iv -o /dev/null http://$test_endpoint_url"

status_code=$(kubectl exec -it --namespace=$namespace deploy/$deployment_name -c $container_name -- \
    sh -c "curl -sS -o /dev/null -w '%{http_code}' http://$test_endpoint_url")

if [[ "$status_code" = "200" ]]; then
    printf "\n%s\n" "------> Result: success <------"
else
    printf "\n%s\n" "------> Result: fail <------"
fi

# ---------------------------------------------------------------------------------------------------------------------

## TODO: not currently implemented
printf "\n\n%s\n\n" "------> Second test run (client -> https -> mesh mTLS -> egress gw -> mTLS origination -> $test_endpoint_url) <------"

kubectl exec -it --namespace=$namespace deploy/$deployment_name -c $container_name -- \
    sh -c "curl -iv -o /dev/null https://$test_endpoint_url"

status_code=$(kubectl exec -it --namespace=$namespace deploy/$deployment_name -c $container_name -- \
    sh -c "curl -sS -o /dev/null -w '%{http_code}' https://$test_endpoint_url")

if [[ "$status_code" = "200" ]]; then
    printf "\n%s\n" "------> Result: success <------"
else
    printf "\n%s\n" "------> Result: fail <------"
fi
# Dynamic Forward Proxy with mTLS in Istio

This demo uses an EnvoyFilter to setup the Dynamic Forward Proxy (DFP) filter with mTLS. This will allow a client to send traffic to the upstream address [mtlsapi.aspnet4you.com](https://mtlsapi.aspnet4you.com) which enforces the client to authenticate with mTLS.

## Prerequisites

1. Create required env vars

    ```bash
    export CLUSTER_OWNER="kasunt"
    export PROJECT="istio-dfp-demo"
    ```

2. Provision cluster

    ```bash
    colima start -p $PROJECT -r containerd -c 4 -m 8 -d 20 --network-address -k --kubernetes-version v1.29.8+k3s1
    ```

3. Install `istioctl` version `1.23.3`.

## Setting Up Istio

```bash
## setting up aspnet4you mTLS client side
kubectl create secret -n istio-system generic istio-egressgateway-certs \
    --from-file=tls.key=config/certs/client.key \
    --from-file=tls.crt=config/certs/client.pem
kubectl create secret -n istio-system generic istio-egressgateway-ca-certs \
    --from-file=ca.crt=config/certs/rootca.pem

## install istio
istioctl operator init
kubectl apply -f istio-provision.yaml
```

## Deploy App and Config

```bash
./apply-config.sh -a
```

## Testing

```bash
./run-test.sh
```

## Clean up

```bash
./apply-config.sh -d

kubectl delete -f istio-provision.yaml

colima stop $PROJECT
```
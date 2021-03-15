# Ingress resource to access the Kubernetes Dashboard from outside the cluster

> These instructions assume the **Kubernetes Dashboard** service endpoints are listening over **HTTPS**.
>

## Deploy the ingress resource

> **TL;DR** Check the following make target:
> ```console
> $ make <target-to-be-added-here>
> ```
>

1. Describe the DNS request mocking.
2. Describe the ingress rule config and deployment
3. Check ingress is actually working (navigate, use token target, etc.)

## Troubleshooting

### Getting error: "Client sent an HTTP request to an HTTPS server."

The reason is the client is initiating an HTTP connection, but the end service is listening over HTTPS.

In this case, add TLS to the Ingress config. talk about annotations here.

### Getting error: HTTP 400 "Connection reset by peer"

If your connection is being rejected by the **Kubernetes Dashboard** service with a message similar to this one:

> 2020/08/28 01:25:58 [error] 2609#2609: *795 readv() failed (104: Connection reset by peer) while reading upstream, client: 10.0.0.25, server: kube.example.com, request: "GET / HTTP/1.1", upstream: "http://10.42.0.2:8443/", host: "kube.example.com"
>

Notice the protocol part of the destination URL trying to be reached: **http://**. This indicates the **Ingress controller** is trying to reach the service via **HTTP** and therefore, the connection is being reset by peer.

To fix this, we need to indicate the **Ingress controller** to

## References:
* https://github.com/helm/charts/issues/5007#issuecomment-425151443
*
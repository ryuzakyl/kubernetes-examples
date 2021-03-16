# Ingress resource to access the Kubernetes Dashboard from outside the cluster

> These instructions assume the **Kubernetes Dashboard** service has been deployed over **HTTPS**, i.e. the service endpoints are expecting **HTTPS** connections.
The **Kubernetes Dashboard** service deployed on this repo is expecting connections over port **8443**.


## Deploy the ingress resource

> **TL;DR** Check the following make target:
> ```console
> $ make <target-to-be-added-here>
> ```
>


For ingress resources, there are mainly two kinds of ingress rules:
* Host-based
* Path-based

> Exposing the **Kubernetes Dashboard** UI over a path would result in an issue: see how to serve (or make accessible) the static assets of the web interface. For that reason, we'll go with the *Host-based* approach.
>
> A *.yaml* config file describing such *Path-based* approach can be consulted at: [dashboard-ingress-path.yaml](dashboard-ingress-path.yaml)
>
> **NOTE:** This file has not been extensively tested. So... *reader discretion is advised*, :stuck_out_tongue_winking_eye:.


The steps required to have the **Kubernetes Dashboard** UI accesible from outside the cluster, we must do the following:

**1. Define the domain where it will be available**

The right way to go here is to buy a domain and make it point to your cloud provided's Load Balancer (or your cluster's [MetalLB](https://metallb.universe.tf/)).

Since this is a simple tutorial, we'll have to "hack" this part. We'll resort to [using an /etc/hosts file for custom domains during development](https://support.acquia.com/hc/en-us/articles/360004175973-Using-an-etc-hosts-file-for-custom-domains-during-development).

Let's say we want to expose the **Kubernetes Dashboard** UI on *k8s-dashboard.com*
Once we've made the changes described on the previous link, we check it is working:

```console
$ nslookup k8s-dashboard.com
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	k8s-dashboard.com
Address: 127.0.0.1
```

**2. Define an ingress resource .yaml config file**

First thing, we need to create a secret needed for HTTPS comunication with the Ingress Controller.

```:ingress/kubernetes-dashboard/dashboard-ingress-host.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard-ingress
  namespace: kubernetes-dashboard
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  rules:
    - host: k8s-dashboard.com
      http:
        paths:
        - pathType: Prefix
          path: /
          backend:
            service:
              name: kubernetes-dashboard
              port:
                number: 443
  tls:
  - secretName: kubernetes-dashboard-tls-secret
    hosts:
      - k8s-dashboard.com

```

**3. Check ingress resource is actually working**

(navigate, use token target, etc.)

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

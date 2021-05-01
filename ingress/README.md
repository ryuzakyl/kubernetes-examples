# Installation

There are several ingress controllers that can be installed: NGINX, Traefik, Ambassador, etc. Next, the install instructions of some of them.

## Kubernetes NGINX ingress controller

In order to deploy/install the Kubernetes NGINX Controller, we use the corresponding (in our case for KinD) manifest files to set it up.

From the [official repo](https://github.com/kubernetes/ingress-nginx), we use the manifest configuration file corresponding to our [specific provider](https://github.com/kubernetes/ingress-nginx/tree/master/deploy/static/provider):

![Provider Ingress](assets/images/manifest-kind.png)

In our case, we'll choose the **deploy.yaml** manifest for `KinD`, which can also be locally found at `ingress/providers/kind/deploy.yaml`.

Once deployed, these are the **Kubernetes objects** created:

![Kubernetes Objects for Ingress](assets/images/nginx-ingress-namespace.png)

## Ambassador ingress controller

> :memo:
>
> For instructions on how to deploy [Ambassador](https://www.getambassador.io/) as an ingress controller, please check [these instructions](https://tutorial.kubernetes-security.info/policies/#preparation_1) (you have to scroll down a bit).

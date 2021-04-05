# Architecture

* https://istio.io/latest/docs/ops/deployment/architecture/
* https://www.infracloud.io/blogs/service-mesh-comparison-istio-vs-linkerd/
* https://www.alibabacloud.com/blog/architecture-analysis-of-istio-the-most-popular-service-mesh-project_597010#:~:text=Envoy's%20discovery%20services%20rely%20on,service%20registry%20to%20discover%20services.

(has an istio architecture image) https://sysdig.com/blog/monitor-istio/

![Istio Architecture](assets/images/istio-arch.svg)

https://www.infracloud.io/blogs/service-mesh-comparison-istio-vs-linkerd/
* Envoy
* Citadel
* Gallery
* etc.

## Control Plane

### Istiod and Service Discovery

https://istio.io/latest/docs/concepts/traffic-management/#introducing-istio-traffic-management

### Istiod as CA

## Data Plane

Istio as CA allows for later mTLS

* (Demystifying Istio's Sidecar Injection Model) https://istio.io/latest/blog/2019/data-plane-setup/

# Installation
<a id="istio-installation"></a>

The first step is to download Istio from the [release page](https://github.com/istio/istio/releases) and download the installation file for your OS, or download and extract the latest release automatically (Linux or macOS).

> :memo: INFO
>
> In these examples Istio **v1.9.0** is the one used.

Once we have extracted the content and navigated inside the folder, there are a couple of folders of interest:

* `bin/` (which contains the [`istioctl`](https://istio.io/latest/docs/reference/commands/istioctl/) client binary)
* `samples/` (having manifests for several `istio-enabled` test applications)

Next, on the terminal, we need to add `istioctl` to our PATH with something like:

```console
$ export PATH=$PWD/bin:$PATH
```

or adding that to the `~/.bashrc` file on our HOME folder.

## Istio install

There several configuration profiles we can user for our `Istio` installation depending on our needs: `default`, `demo`, `minimal`, `remote`, `empty` and `preview`. For more details and proper scenarios for these profiles, please read the [official docs](https://istio.io/latest/docs/setup/additional-setup/config-profiles/) regarding this.

As a quick reference, the components marked as **✔** are installed within each profile:

|                            | default | demo | minimal | remote | empty | preview |
|:--------------------------:|:-------:|:----:|:-------:|:------:|:-----:|:-------:|
| Core components            |         |      |         |        |       |         |
|       istio-egressgateway  |         | ✔    |         |        |       |         |
|       istio-ingressgateway | ✔       | ✔    |         |        |       | ✔       |
|       istiod               | ✔       | ✔    | ✔       |        |       | ✔       |

> :eyes:
>
> For our examples, the profile selected is `demo`, as it’s selected to have a good set of defaults for testing, but there are other profiles for production or performance testing.

To install/enable Istio on your cluster:

```console
$ istioctl install --set profile=demo -y
```

Here we can see the components installed:

![Istio intall command](assets/images/istio-install.png)

In order to
![istio-system namespace](assets/images/istio-system-namespace.png)

Inside the `istio-system` namespace, we can see a pod for [`istiod`](https://istio.io/latest/blog/2020/istiod/) and [`istio-ingressgateway`](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/):
![istio-system pods](assets/images/istio-system-pods.png)

For more information about `Gateway` on Istion, please check [this](https://istio.io/latest/docs/reference/config/networking/gateway/).

## `istioctl analyze`

`istioctl analyze` is a diagnostic tool that detects potential issues with your Istio configuration, as well as gives general insights to improve your configuration. It can run against a live cluster or a set of local configuration files. It can also run against a combination of the two, allowing you to catch problems before you apply changes to a cluster.

> :memo:
>
> For more details on how to use and the capabilities of `istioctl analyze`, please check [this](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl-analyze/) and [this](https://istio.io/latest/blog/2019/introducing-istioctl-analyze/).

We can analyze your current live Kubernetes cluster by running:

```console
$ istioctl analyze
```

We get the following:

![Istioctl Analyze](assets/images/istioctl-analyze.png)

This means we forgot to enable Istio injection (a very common issue). In order to fix it we can do the following:

```console
$ kubectl label namespace default istio-injection=enabled
```

This adds a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later. If we run our analysis again, we see that everything is fine now:

![Istio configuration OK](assets/images/istio-config-ok.png)
# Istio Ingress Gateway

alternative to NGINX Ingress Controller
min 13:30 of https://www.youtube.com/watch?v=16fgzklcF7Y

# Observability

Once we have Istio installed...

## Prometheus + Grafana

* https://istio.io/latest/docs/ops/integrations/prometheus/
* https://www.istiobyexample.dev/prometheus
* https://istio.io/latest/docs/tasks/observability/metrics/using-istio-dashboard/

## Kiali

* https://istio.io/latest/docs/tasks/observability/kiali/

# Istio-enabled application: Requirements

There are some implications of Istio’s sidecar model that may need special consideration when deploying an Istio-enabled application. This document describes these application considerations and specific requirements of Istio enablement.

https://istio.io/latest/docs/ops/deployment/requirements/

# Advanced deployments

https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/docs/service-mesh.md

# Software Patterns

* (Istio in Production: Day 2 Traffic Routing (Cloud Next '19)) https://www.youtube.com/watch?v=7cINRP0BFY8
* (Microservices in the Cloud with Kubernetes and Istio (Google I/O '18)) https://www.youtube.com/watch?v=gauOI0O9fRM, ....projects/github/thesandlord/Istio101
* https://www.youtube.com/watch?v=wCJrdKdD6UM&t=586s (canary, etc.)

**Circuit breaker:**
* https://istio.io/latest/docs/tasks/traffic-management/circuit-breaking/
* https://developers.redhat.com/blog/2018/03/27/istio-circuit-breaker-when-failure-is-an-option/
* https://dzone.com/articles/resilient-microservices-with-istio-circuit-breaker
* https://www.exoscale.com/syslog/istio-vs-hystrix-circuit-breaker/
* https://www.youtube.com/watch?v=JbFdFGoTA6U

**Chaos Enineering with Fault Injection**

* my Post 97th

# Security with Istio

* https://github.com/GoogleCloudPlatform/istio-samples/tree/6fa69cf46424c055535ddbdc22f715e866c4d179/security-intro#demo-introduction-to-istio-security

* (External services into the mesh) https://www.istiobyexample.dev/external-services
* (Authorization in Istio) https://www.istiobyexample.dev/authorization
* (Istio Ingress/Gateway) https://www.istiobyexample.dev/ingress


# Observability of Istio components

## Logging
* https://istio.io/latest/docs/tasks/observability/logs/
* https://istio.io/latest/docs/tasks/observability/logs/access-log/
* https://istio.io/latest/docs/ops/diagnostic-tools/component-logging/
* https://logz.io/blog/logging-istio-with-elk-and-logz-io/
* Datadog (https://www.datadoghq.com/blog/istio-monitoring-tools/, https://www.datadoghq.com/blog/istio-monitoring-tools/#istio-and-envoy-logging, https://www.datadoghq.com/blog/how-to-monitor-istiod/)
* https://itnext.io/customising-istio-access-logs-e5805eea31b7

## Metrics

Of Istio's internal components

## Tracing

Of Istio's internal components

# Managed Istio solutions

* (Banzai Clound: Backyards) https://banzaicloud.com/products/backyards/, https://banzaicloud.com/products/backyards/pricing/
* (IBM Cloud) https://www.ibm.com/cloud/blog/announcements/managed-istio-on-ibm-cloud-kubernetes-service-now-ga
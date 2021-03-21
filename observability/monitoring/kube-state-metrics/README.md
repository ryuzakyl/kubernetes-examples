# How to install?

From the official [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) repository:
> To deploy this project, you can simply run `kubectl apply -f examples/standard` and a Kubernetes service and deployment will be created.

Therefore, the instructions would be the following:
```console
$ git clone https://github.com/kubernetes/kube-state-metrics.git
$ cd kube-state-metrics
$ kubectl apply -f examples/standard
```

> :warning: NOTE
>
> Some environments, including GKE clusters, have restrictive permissions settings that require a different installation approach. Details on deploying kube-state-metrics to GKE clusters and other restricted environments are available in the [kube-state-metrics docs](https://github.com/kubernetes/kube-state-metrics#usage).

# Collecting cluster state metrics

Once `kube-state-metrics` is deployed to your cluster, it provides a vast array of metrics in text format on an HTTP endpoint. The metrics are exposed in [Prometheus exposition format](https://www.datadoghq.com/blog/monitor-prometheus-metrics/), so they can be easily consumed by any monitoring system that can collect Prometheus metrics.

To browse the metrics, you can do one of the following:
1. Start an HTTP proxy
2. With an Ingress Rule

## 1. Start an HTTP proxy

One of the ways of exposing this service to be reachable from outside the cluster is:

```console
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```

The text-based metrics can be viewed at http://localhost:8001/api/v1/namespaces/kube-system/services/kube-state-metrics:http-metrics/proxy/metrics or by sending a `curl` request to the same endpoint:

![kube-state-metrics-proxy.png](assets/images/kube-state-metrics-proxy.png)

## 2. With an Ingress Rule

With the following `.yaml` config file, we can expose the `kube-state-metrics` service from outside the cluster:

![yaml-config-file.png](assets/images/yaml-config-file.png)

The `kube-state-metrics` home page is available at the specified location:
![kube-state-metrics-svc-home.png](assets/images/kube-state-metrics-svc-home.png)

The actual metrics (as seen with the proxy approach) can be found on the `/metrics` endpoint:
![kube-state-metrics-ingress.png](assets/images/kube-state-metrics-ingress.png)

# `kube-state-metrics` on Sysdig Monitor

https://sysdig.com/blog/introducing-kube-state-metrics/

# `kube-state-metrics` on Grafana

https://grafana.com/grafana/dashboards/13332

# Other References:
* https://www.datadoghq.com/blog/how-to-collect-and-graph-kubernetes-metrics

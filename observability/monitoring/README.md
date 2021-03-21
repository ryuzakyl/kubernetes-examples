
# Monitoring Kubernetes

* TFM/reports-and-guides/sysdig/pf-kubernetes-monitoring-fundamentals.pdf
* https://www.datadoghq.com/blog/monitoring-kubernetes-era/#what-does-kubernetes-mean-for-your-monitoring

# metrics-server

### What?

From the official GitHub [repository](https://github.com/kubernetes-sigs/metrics-server):

> Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.
>
> Metrics Server is not meant for non-autoscaling purposes. For example, don't use it to forward metrics to monitoring solutions, or as a source of monitoring solution metrics.

**NOTE:** To simplify, *metrics-server* is meant for monitoring aggregation (read more [here](https://instrumentalapp.com/blog/what-does-monitoring-aggregation-and-resolution-mean/) and [here](https://www.logsign.com/blog/what-is-log-aggregation-and-monitoring-relation-in-cybersecurity/)) and simple metrics like CPU usage, load averages, bandwidth, and disk I/O. Basic metrics are useful for capacity planning and identifying unhealthy worker nodes.

### Why?

Again, from the [repo](https://github.com/kubernetes-sigs/metrics-server):

> You can use Metrics Server for:
> * CPU/Memory based horizontal autoscaling (learn more about Horizontal Pod Autoscaler)
> * Automatically adjusting/suggesting resources needed by containers (learn more about Vertical Pod Autoscaler)
>
> Don't use Metrics Server when you need:
> * Non-Kubernetes clusters
> * An accurate source of resource usage metrics
> * Horizontal autoscaling based on other resources than CPU/Memory

**NOTE:** For unsupported use cases, check out full monitoring solutions like [Prometheus](https://prometheus.io/) (or the [Section](#prometheus-section) on these examples).

To know how to deploy it and work with it, please check the [metrics-server documentation](metrics-server/README.md) on these examples.

# kube-state-metrics

**NOTE:** As we discussed on the previous section, for monitoring **Basic metrics** in our cluster we can use *metrics-server*. In case we need some **[Advanced metrics](https://www.digitalocean.com/docs/kubernetes/how-to/monitor-advanced/)** like deployment status metrics, like DaemonSet pod scheduling and availability; we need something else. Advanced metrics are useful for in-depth views into `Kubernetes-specific` metrics.

In order to use advanced monitoring, we're required to install the sidecar agent `kube-state-metrics`.

If we need to complement these advanced metrics, we can resort to [service meshes](https://www.nginx.com/blog/what-is-a-service-mesh/) like [Linkerd](https://linkerd.io/) or [Istio](https://istio.io/) (see [Istio Section](#istio-section)).

## What is `kube-state-metrics`?

`kube-state-metrics` is an open source project designed to generate metrics derived from the state of [Kubernetes objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/) – the abstractions Kubernetes uses to represent your cluster. With this information you can monitor details such as:
* State of nodes, pods, and jobs
* Compliance with replicaSets specs
* Resource requests and min/max limits

`kube-state-metrics` talks to Kubernetes API server to get all the details about all the API objects like deployments, pods, daemonsets etc. Basically it provides kubernetes API object metrics which you cannot get directly from native Kubernetes monitoring components.

> :information_source: NOTE
>
> By default, `kube-state-metrics` exposes several metrics for events across your cluster. If you have a large number of frequently-updating resources on your cluster, you may find that a lot of data is ingested into these metrics. This can incur high costs on some cloud providers. Please take a moment to configure what metrics you'd like to expose, as well as consult the documentation for your Kubernetes environment in order to avoid unexpectedly high costs.

## kube-state-metrics vs. metrics-server

The `metrics-server` is a project that has been inspired by Heapster and is implemented to serve the goals of core metrics pipelines in Kubernetes monitoring architecture. It is a cluster level component which periodically scrapes metrics from all Kubernetes nodes served by Kubelet through Summary API. The metrics are aggregated, stored in memory and served in Metrics API format. The `metrics-server` stores the latest values only and is not responsible for forwarding metrics to third-party destinations.

`kube-state-metrics` is focused on generating completely new metrics from Kubernetes' object state (e.g. metrics based on deployments, replica sets, etc.). It holds an entire snapshot of Kubernetes state in memory and continuously generates new metrics based off of it. And just like the `metrics-server` it too is not responsible for exporting its metrics anywhere.

> :information_source: NOTE
>
> The `kube-state-metrics` is an exporter that allows **Prometheus** to scrape that information as well.

For installation instructions and more details check [here](kube-state-metrics/README.md).

# Prometheus
<a name="prometheus-section"></a>

* https://sysdig.com/blog/kubernetes-monitoring-prometheus/

* https://www.replex.io/blog/kubernetes-in-production-the-ultimate-guide-to-monitoring-resource-metrics

* https://www.itopstimes.com/monitor/problems-and-solutions-of-monitoring-your-kubernetes-operators/

# Istio
<a id="istio-section"></a>

# Datadog

Kubernetes includes several useful monitoring tools, both as built-in features and cluster add-ons. The available tooling is valuable for spot checks and retrieving metric snapshots, and can even display several minutes of monitoring data in some cases.

For monitoring production environments, you need visibility into your Kubernetes infrastructure as well as your containerized applications themselves, with much longer data retention and lookback times. Using a monitoring service can also give you access to metrics from your Control Plane, providing more insight into your cluster’s health and performance.

For more information check [here](datadog/README.md).

:tada::confetti_ball: **FREE Datadog accounts for students** (without Log Management?):
* https://www.datadoghq.com/blog/datadog-github-student-developer-pack/
* https://www.datadoghq.com/blog/datadog-github-student-developer-pack/

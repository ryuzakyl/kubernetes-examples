
# Monitoring Kubernetes

* TFM/reports-and-guides/sysdig/pf-kubernetes-monitoring-fundamentals.pdf
* https://www.datadoghq.com/blog/monitoring-kubernetes-era/#what-does-kubernetes-mean-for-your-monitoring

# metrics-server

### What?

From the official GitHub [repository](https://github.com/kubernetes-sigs/metrics-server):

> Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.
>
> Metrics Server is not meant for non-autoscaling purposes. For example, don't use it to forward metrics to monitoring solutions, or as a source of monitoring solution metrics.

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

* https://github.com/kubernetes/kube-state-metrics

* https://www.datadoghq.com/blog/how-to-collect-and-graph-kubernetes-metrics/#add-kube-state-metrics-to-your-cluster

# Prometheus
<a name="prometheus-section"></a>

* https://sysdig.com/blog/kubernetes-monitoring-prometheus/

* https://www.replex.io/blog/kubernetes-in-production-the-ultimate-guide-to-monitoring-resource-metrics

# Istio

# Datadog

Kubernetes includes several useful monitoring tools, both as built-in features and cluster add-ons. The available tooling is valuable for spot checks and retrieving metric snapshots, and can even display several minutes of monitoring data in some cases.

For monitoring production environments, you need visibility into your Kubernetes infrastructure as well as your containerized applications themselves, with much longer data retention and lookback times. Using a monitoring service can also give you access to metrics from your Control Plane, providing more insight into your cluster’s health and performance.

For more information check [here](datadog/README.md).

:tada::confetti_ball: **FREE Datadog accounts for students** (without Log Management?):
* https://www.datadoghq.com/blog/datadog-github-student-developer-pack/
* https://www.datadoghq.com/blog/datadog-github-student-developer-pack/

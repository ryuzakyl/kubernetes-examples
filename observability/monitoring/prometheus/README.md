
General description about Prometheus.

# Install

https://github.com/prometheus-operator/kube-prometheus#apply-the-kube-prometheus-stack

https://www.youtube.com/watch?v=QoDqxm7ybLc

Several approaches:
1. Manually create and apply (in the required order) all config files
2. Using an operator (Manager of Prometheus components)
3. User Helm chart to deploy the operator


4:40 (https://www.youtube.com/watch?v=QoDqxm7ybLc) explanation of kubernetes objects created and their function

# Architecture

* (Prometheus basic architecture) https://www.programmersought.com/article/16474076685/

# Metric Types

https://prometheus.io/docs/concepts/metric_types/

1. Counter
2. Gauge
3. Histogram (https://prometheus.io/docs/practices/histograms/, https://www.robustperception.io/how-does-a-prometheus-histogram-work)

## Prometheus metrics compatibility

[Software exposing Prometheus metrics](https://prometheus.io/docs/instrumenting/exporters/#software-exposing-prometheus-metrics)

# Exporters and monitoring Applications

https://www.scalyr.com/blog/prometheus-metrics-by-example/
https://www.youtube.com/watch?v=h4Sl21AKiDg

Describe scenarios of using and writing exporters to expose Prometheus metrics at `/metrics` and instrumenting your applications with Prometheus client libraries.

## Exporters

https://prometheus.io/docs/instrumenting/exporters/

* DB
* Hardware
* Issue Trackers and CI
* Messaging systems
* Storage
* HTTP
* APIs
* Logging
* Other monitoring systems
* Miscellaneous

## Monitoring Applications

Example of metrics for your app:
* How many requests?
* How many exceptions?
* How many server resources are used?

USE method (http://www.brendangregg.com/usemethod.html) and TSA method (http://www.brendangregg.com/tsamethod.html)?

https://prometheus.io/docs/instrumenting/clientlibs/
https://github.com/prometheus/client_python

# Pull system

Advantages over push approach of New Relic or Amazon Cloud Watch

min 12:00 of https://www.youtube.com/watch?v=h4Sl21AKiDg

* (push vs. pull) https://giedrius.blog/2019/05/11/push-vs-pull-in-monitoring-systems/
* https://prometheus.io/blog/2016/07/23/pull-does-not-scale-or-does-it/#:~:text=A%20pull%20approach%20not%20only,or%20inspect%20metrics%20endpoints%20manually.
* https://thenewstack.io/exploring-prometheus-use-cases-brian-brazil/

# Prometheus rules

https://prometheus.io/docs/practices/rules/

Rule examples: https://awesome-prometheus-alerts.grep.to/rules.html

"Unit testing" for rules: https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/

## Recording rules

Is this the same as rules for "aggregating metrics values"?

https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/

## Alerting rules

The alert defined by these kind of rules are triggered by the **Alert Manager**

https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/

# Prometheus Data Storage

By default Prometheus store data on SSD/HDD, but it can be integrated with Remote Storage Systems (i.e., relational DBs, etc.) and the data is stored in a Custom Time Series Format


## Integration with Remote Storage Systems

[Remote storage integrations](https://prometheus.io/docs/prometheus/latest/storage/#remote-storage-integrations)

https://prometheus.io/docs/operating/integrations/#remote-endpoints-and-storage
https://valyala.medium.com/analyzing-prometheus-data-with-external-tools-5f3e5e147639

# Scaling Prometheus with Cortex

Why do need this? min 20:00 of https://www.youtube.com/watch?v=h4Sl21AKiDg

Handling hundreds of services we might want to have multiple Prometheus servers that aggregate all these metrics data and configuring that and scaling Prometheus in that way can be very difficult.

We can:
1. Increase capacity of Prometheus server so it can store more metrics data
2. Limit number of metrics that Prometheus collects from the applications/targets (keep only relevant ones)
3. Prometheus at scale

Other links:
* https://github.com/cortexproject/cortex
* https://www.cncf.io/blog/2018/12/18/cortex-a-multi-tenant-horizontally-scalable-prometheus-as-a-service/
* https://grafana.com/go/webinar/taking-prometheus-to-scale-with-cortex/
* https://platform9.com/blog/kubernetes-monitoring-at-scale-with-prometheus-and-cortex/

# Visualization

https://github.com/prometheus-operator/kube-prometheus#access-the-dashboards

https://github.com/prometheus-operator/kube-prometheus/blob/main/docs/exposing-prometheus-alertmanager-grafana-ingress.md

## Prometheus UI

Deploy an ingress?

## Grafana

Deploy an ingress?


# Other References:
* [Youtube: How Prometheus Monitoring works | Prometheus Architecture explained](https://www.youtube.com/watch?v=h4Sl21AKiDg)
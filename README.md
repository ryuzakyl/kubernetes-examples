# kubernetes-examples
Kubernetes examples for beginners

## Hardware specifications

In case it is relevant for the reader, these are the hardware specifications where all the examples on this repo were tested:

> Linux matrix 5.0.0-32-generic #34~18.04.2-Ubuntu SMP Thu Oct 10 10:36:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

## Setting up Kubernetes

> **TL;DR** To install KinD and create a 3 node (1 control plane and 2 workers) Kubernetes cluster, simply run:
>
> ```console
> $ make kind-install
> $ make create-cluster
> ```

### Choosing a Kubernetes installer

There are several Kubernetes installers for a development environment ([read more](https://www.padok.fr/en/blog/minikube-kubeadm-kind-k3s)). Some of those are:
* Minikube
* Kubeadm
* KinD
* K3S

In these examples the tool chosen to create and configure a Kubernetes cluster was [KinD](https://kind.sigs.k8s.io/).

**Why KinD?**

From the KinD home page:
> * kind supports multi-node (including HA) clusters
> * kind supports building Kubernetes release builds from source
> * support for make / bash / docker, or bazel, in addition to pre-published builds
> * kind supports Linux, macOS and Windows
> * kind is a [CNCF certified conformant Kubernetes installer](https://landscape.cncf.io/?selected=kind).

### Creating the cluster

**Installing KinD**

**KinD** is a single binary that can be executed on Linux, macOS and Windows. We can download it from the [release page](https://github.com/kubernetes-sigs/kind/releases/) of the official **GitHub** [repo](https://github.com/kubernetes-sigs/kind) or we can follow the Quick Start [guide](https://kind.sigs.k8s.io/docs/user/quick-start#installation). We'll go with the latter.

> ```console
> $ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0
> $ chmod +x ./kind
> $ mv ./kind /usr/bin/kind
> ```

**NOTE:** The version used is v0.10.0, the latest one when writing this documentation.

**Creating a Kubernetes cluster**

To create clusters with KinD, we only need to run two commands (the 2nd one is "optional") ([learn more](https://kind.sigs.k8s.io/docs/user/quick-start#creating-a-cluster)):
> create cluster --name {{cluster-name}} --config {{config-file-path}}
> kubectl config set-context kind-{{cluster-name}}

**NOTE:** For the examples of this repository, we need an **ingress enabled** KinD cluster. The configuration file for this kind of cluster makes use of two extra arguments ([read more](https://kind.sigs.k8s.io/docs/user/ingress/#create-cluster)):
* **extraPortMappings** allow the local host to make requests to the Ingress controller over ports 80/443
* **node-labels** only allow the ingress controller to run on a specific node(s) matching the label selector

The final confguration file for KinD is at [kind/configs/ingress-enabled-config.yaml](kind/configs/ingress-enabled-config.yaml).

### Interacting with the cluster

From the Quick Start [guide](https://kind.sigs.k8s.io/docs/user/quick-start/#interacting-with-your-cluster):

> After creating a cluster, you can use kubectl to interact with it by using the configuration file generated by kind.
>
> By default, the cluster access configuration is stored in **${HOME}/.kube/config** if **$KUBECONFIG** environment variable is not set.
>
> If **$KUBECONFIG** environment variable is set, then it is used as a list of paths (normal path delimiting rules for your system). These paths are merged. When a value is modified, it is modified in the file that defines the stanza. When a value is created, it is created in the first file that exists. If no files in the chain exist, then it creates the last file in the list.

**NOTE:** For these examples, the generated **kubeconfig** file was moved to a specific folder and the following entry was added to the *~/.bashrc* file:

> ```console
> $ export KUBECONFIG=/path/to/folder/with/kubeconfig
> ```

## Observability

### Monitoring/Metrics

As the number of cyber attacks rise, it???s important for cloud monitoring services to detect possible breaches, identify security gaps, and secure the network well before an attack happens.

For more details about Cloud Monitoring, please check [this](https://www.nutanix.com/info/cloud-monitoring).

For the examples tried on this project, please check [here](observability/monitoring/README.md).

### Tracing

* Jaeger
* Zipkin
* OpenCensus
* Cilium, Hubble
* OpenTracing

### Logging

* https://thenewstack.io/logging-for-kubernetes-what-to-log-and-how-to-log-it/
* (logging with Fluentd) https://medium.com/hashmapinc/application-logging-simplified-in-kubernetes-part-1-5ba603a1744b
* (section Kubernetes logging tools) https://logz.io/blog/a-practical-guide-to-kubernetes-logging/

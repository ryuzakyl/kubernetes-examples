This application displays information about a book, similar to a single catalog entry of an online book store. Displayed on the page is a description of the book, book details (ISBN, number of pages, and so on), and a few book reviews.

# Architecture

The Bookinfo application is broken into four separate microservices (see image):

* `productpage`. The `productpage` microservice calls the details and reviews microservices to populate the page.
* `details`. The `details` microservice contains book information.
* `reviews`. The `reviews` microservice contains book reviews. It also calls the ratings microservice.
* `ratings`. The `ratings` microservice contains book ranking information that accompanies a book review.

![Architecture No Istio](assets/images/noistio.svg)

> :memo: NOTE
>
> There are 3 versions of the reviews microservice:
> * Version v1 doesn’t call the ratings service.
> * Version v2 calls the ratings service, and displays each rating as 1 to 5 black stars.
> * Version v3 calls the ratings service, and displays each rating as 1 to 5 red stars.

The application is polyglot, i.e., the microservices are written in different languages. It’s worth noting that these services have no dependencies on Istio, but make an interesting service mesh example, particularly because of the multitude of services, languages and versions for the reviews service.

# Installation

In order to deploy the `Bookinfo` sample application we must apply the manifest shipped with Istio when installed. For more details about Istio installation, please check [`service-meshes/istio/README.md`](../../service-meshes/istio/README.md#istio-installation)

Once inside the istio installation folder (mine's at `HOME/istio-1.9.0`), we proceed to apply the manifest located at [`samples/bookinfo/platform/kube/bookinfo.yaml`](https://github.com/istio/istio/blob/master/samples/bookinfo/platform/kube/bookinfo.yaml):

```console
$ kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

The deployment is made on an `Istio-enabled` Kubernetes cluster as mentioned [`before`](../../service-meshes/istio/README.md#istio-installation), Envoy sidecars are injected along side each service. The resulting deployment will look like this:

![Architecture No Istio](assets/images/withistio.svg)

All of the microservices will be packaged with an `Envoy` sidecar that intercepts incoming and outgoing calls for the services, providing the hooks needed to externally control, via the Istio control plane, routing, telemetry collection, and policy enforcement for the application as a whole.

In order to confirm all services and pods (all pods are ready `2/2`)are correctly defined run:

![Bookinfo App objects](assets/images/bookinfo-app-objects.png)

To confirm that the Bookinfo application is running, send a request to it by a `curl` command from some pod, for example from `ratings`:

```console
RATINGS_POD="$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')"
URL="productpage:9080/productpage"
kubectl exec $RATINGS_POD -c ratings -- curl -sS $URL | grep -o "<title>.*</title>"
```


# Other References
* https://istio.io/latest/docs/examples/bookinfo/

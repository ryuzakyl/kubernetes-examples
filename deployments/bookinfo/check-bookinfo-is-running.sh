RATINGS_POD="$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')"
URL="productpage:9080/productpage"
kubectl exec $RATINGS_POD -c ratings -- curl -sS $URL | grep -o "<title>.*</title>"


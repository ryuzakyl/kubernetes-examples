# References:
# . https://github.com/MartinHeinz/python-project-blueprint/blob/master/Makefile#L12

# This version-strategy uses git tags to set the version string
TAG := v0.0.1

ROOTDIR := $(realpath .)

CONFIG_FILE := ingress-enabled-config.yaml

ISTIO_INSTALLER_PATH :=  ~/istio-1.9.0
PRODUCT_PAGE_URL := productpage:9080/productpage


# Reset
Off=\033[0m       # Text Reset

# Regular Colors
Black=\033[0;30m        # Black
Red=\033[0;31m          # Red
Green=\033[0;32m        # Green
Yellow=\033[0;33m       # Yellow
Blue=\033[0;34m         # Blue
Purple=\033[0;35m       # Purple
Cyan=\033[0;36m         # Cyan
White=\033[0;37m        # White

# Bold
BBlack=\033[1;30m       # Black
BRed=\033[1;31m         # Red
BGreen=\033[1;32m       # Green
BYellow=\033[1;33m      # Yellow
BBlue=\033[1;34m        # Blue
BPurple=\033[1;35m      # Purple
BCyan=\033[1;36m        # Cyan
BWhite=\033[1;37m       # White

# Underline
UBlack=\033[4;30m       # Black
URed=\033[4;31m         # Red
UGreen=\033[4;32m       # Green
UYellow=\033[4;33m      # Yellow
UBlue=\033[4;34m        # Blue
UPurple=\033[4;35m      # Purple
UCyan=\033[4;36m        # Cyan
UWhite=\033[4;37m       # White

# Background
On_Black=\033[40m       # Black
On_Red=\033[41m         # Red
On_Green=\033[42m       # Green
On_Yellow=\033[43m      # Yellow
On_Blue=\033[44m        # Blue
On_Purple=\033[45m      # Purple
On_Cyan=\033[46m        # Cyan
On_White=\033[47m       # White

# High Intensty
IBlack=\033[0;90m       # Black
IRed=\033[0;91m         # Red
IGreen=\033[0;92m       # Green
IYellow=\033[0;93m      # Yellow
IBlue=\033[0;94m        # Blue
IPurple=\033[0;95m      # Purple
ICyan=\033[0;96m        # Cyan
IWhite=\033[0;97m       # White

# Bold High Intensty
BIBlack=\033[1;90m      # Black
BIRed=\033[1;91m        # Red
BIGreen=\033[1;92m      # Green
BIYellow=\033[1;93m     # Yellow
BIBlue=\033[1;94m       # Blue
BIPurple=\033[1;95m     # Purple
BICyan=\033[1;96m       # Cyan
BIWhite=\033[1;97m      # White

# High Intensty backgrounds
On_IBlack=\033[0;100m   # Black
On_IRed=\033[0;101m     # Red
On_IGreen=\033[0;102m   # Green
On_IYellow=\033[0;103m  # Yellow
On_IBlue=\033[0;104m    # Blue
On_IPurple=\033[10;95m  # Purple
On_ICyan=\033[0;106m    # Cyan
On_IWhite=\033[0;107m   # White

# -------------------------------------------------

version:
	@echo $(TAG)

kind-install:
	@curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0
	@chmod +x ./kind
	@mv ./kind /usr/bin/kind

install-python-packages:
	pip3 install colorama

create-cluster:
ifndef name
	@echo A cluster 'name' must be provided
	@echo Usage:
	@echo 	make create-cluster name=<cluster-name>
else
	@echo "Creating cluster named $(name)..."
	@echo Config file used: ./src/kind/configs/$(CONFIG_FILE)
	@kind create cluster --name $(name) --config $(ROOTDIR)/kind/configs/$(CONFIG_FILE)
	@kubectl config set-context kind-$(name)
endif

delete-cluster:
ifndef name
	@echo "A cluster 'name' must be provided"
	@echo Usage:
	@echo 	"\tmake cluster-delete name=<cluster-name>";
else
	@echo Deleting cluster named $(name)...
	@kind delete cluster --name $(name)
endif

restart-cluster:
ifndef name
	@echo "A cluster 'name' must be provided"
	@echo Usage:
	@echo 	"\tmake restart-cluster name=<cluster-name>";
else
	@echo Restarting cluster named $(name)...
	# @kind get nodes --name $(name)

	$(eval KIND_CONTAINERS := $(shell kind get nodes --name $(name) | `sed 's/$/,/'`))
	@echo KIND_CONTAINERS;

	for container in "${KIND_CONTAINERS[@]}"; do
		echo "Stopping node '$container'";
		# docker container stop $container
	done

	echo "";
	echo "-------------------------------------------------------";
	echo "";

	for container in "${KIND_CONTAINERS[@]}"; do
		echo "Starting node '$container'";
		# docker start $container && docker exec $container sh -c 'mount -o remount,ro /sys; kill -USR1 1'
	done
endif

deploy-nginx-ingress-controller:
	@echo "Deploying NGINX Ingress for KinD..."
	@kubectl apply -f ingress/providers/kind/deploy.yaml
	@echo ""
	@echo "Monitor status with: 'watch kubectl get all -n ingress-nginx'"

check-nginx-ingress-controller:
	@curl -k https://localhost

deploy-fruits-demo:
	@kubectl apply -f deployments/fruits/

deploy-fruits-ingress:
	@kubectl apply -f ingress/fruits/fruits-ingress.yaml

deploy-kubernetes-dashboard:
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
	@kubectl apply -f deployments/kubernetes-dashboard/cluster-role-binding.yaml
	@kubectl apply -f deployments/kubernetes-dashboard/dashboard-adminuser.yaml

uninstall-kubernetes-dashboard:
	@kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
	@kubectl delete -f deployments/kubernetes-dashboard/dashboard-adminuser.yaml
	@kubectl delete -f deployments/kubernetes-dashboard/cluster-role-binding.yaml

get-dashboard-login-token:
	$(eval ADMIN_SECRET_NAME := $(shell kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}"))
	$(eval TOKEN := $(shell kubectl -n kubernetes-dashboard get secret $(ADMIN_SECRET_NAME) -o go-template="{{.data.token | base64decode}}"))
	@echo "Token to access the Kubernetes Dashboard:";
	@echo $(TOKEN)

deploy-dashboard-path-ingress:
	@echo "Deploying ingress for Kubernetes Dashboard...";
	@kubectl apply -f ingress/kubernetes-dashboard/dashboard-ingress-path.yaml
	@echo "Visit Kubernetes Dashboard at /kubernetes-dashboard";

deploy-kube-state-metrics:
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/service-account.yaml
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/cluster-role.yaml
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/cluster-role-binding.yaml
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/service.yaml
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/deployment.yaml

uninstall-kube-state-metrics:
	@kubectl delete -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/service-account.yaml
	@kubectl delete -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/cluster-role.yaml
	@kubectl delete -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/cluster-role-binding.yaml
	@kubectl delete -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/service.yaml
	@kubectl delete -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/deployment.yaml

deploy-prometheus-stack:
	@echo "Deploying Prometheus monitoring stack";
	@kubectl apply -f observability/monitoring/prometheus/manifests/setup
	@kubectl apply -f observability/monitoring/prometheus/manifests/
	@echo "Check deployment status with the following command:";
	@echo "watch kubectl get all -n monitoring";

uninstall-prometheus-stack:
	@echo "Uninstalling Prometheus monitoring stack";
	@kubectl delete -f observability/monitoring/prometheus/manifests/
	@kubectl delete -f observability/monitoring/prometheus/manifests/setup

install-istio:
	@echo "Installing istio with automatic sidecar injection..."
	@istioctl install --set profile=demo -y
	@kubectl label namespace default istio-injection=enabled
	@echo ""
	@echo "Please check:";
	@echo "watch kubectl get all -n istio-system "

deploy-bookinfo-app:
	@kubectl apply -f $(ISTIO_INSTALLER_PATH)/samples/bookinfo/platform/kube/bookinfo.yaml

check-bookinfo-app-is-deployed:
	$(eval RATINGS_POD := $(shell kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}'))
	@kubectl exec $(RATINGS_POD) -c ratings -- curl -sS $(PRODUCT_PAGE_URL) | grep -o "<title>.*</title>"

deploy-istio-gateway-for-bookinfo:
	@kubectl apply -f $(ISTIO_INSTALLER_PATH)/samples/bookinfo/networking/bookinfo-gateway.yaml

# https://github.com/kubernetes/dashboard/blob/master/docs/user/certificate-management.md
# https://www.ssls.com/knowledgebase/how-to-fill-in-the-san-fields-in-the-csr/

# kubectl create secret tls kubernetes-dashboard-tls-secret --namespace="kubernetes-dashboard" --key="dashboard.key" --cert="dashboard.crt"
# https://shocksolution.com/2018/12/14/creating-kubernetes-secrets-using-tls-ssl-as-an-example/


# openssl req -new -out dashboard.csr -newkey rsa:2048 -nodes -sha256 -keyout dashboard.key -config dashboard-req.conf
# openssl x509 -req -sha256 -days 365 -in dashboard.csr -signkey dashboard.key -out dashboard.crt



# create secret imperative
# kubectl create secret tls test-tls --key="tls.key" --cert="tls.crt"
# https://shocksolution.com/2018/12/14/creating-kubernetes-secrets-using-tls-ssl-as-an-example/
# kubectl create secret tls kubernetes-dashboard-tls-secret --namespace="kubernetes-dashboard" --key="dashboard.key" --cert="dashboard.crt"

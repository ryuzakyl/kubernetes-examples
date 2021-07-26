# References:
# . https://github.com/MartinHeinz/python-project-blueprint/blob/master/Makefile#L12

# This version-strategy uses git tags to set the version string
TAG := v0.0.1

ROOTDIR := $(realpath .)

# ------------- Ingress -------------
# CONFIG_FILE := ingress-enabled-config.yaml
# CONFIG_FILE := ingress-enabled-ephemeral-config.yaml

# ------------- Networking -------------
# CONFIG_FILE := calico-enabled-config.yaml
# CONFIG_FILE := cilium-enabled-config.yaml

# ------------- Security -------------
# CONFIG_FILE := vulnerable-etcd-config.yaml
# CONFIG_FILE := vulnerable-kubelet-config.yaml

# CONFIG_FILE := outdated-cluster-config.yaml
# CONFIG_FILE := vulnerable-cluster-config.yaml
# CONFIG_FILE := falco-cluster-config.yaml
CONFIG_FILE := secured-cluster-config.yaml


ISTIO_INSTALLER_PATH := ~/tools/istio-1.10.0
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
	@kind create cluster --name $(name) --config $(ROOTDIR)/kind/configs/$(CONFIG_FILE) --retain
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

# ---------------------------------------------------------------------------

setup-attack-scenario-02-pre:
#	creating cluster
	@echo "Creating cluster for Scenario 2...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/cilium-enabled-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."

#	intalling cilium
	@echo "Installing Cilium...";
	@kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.9/install/kubernetes/quick-install.yaml
	@echo "";

# 	installing cilium hubble
	@echo "Installing Cilium Hubble..."
	@kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.9/install/kubernetes/quick-hubble-install.yaml

# 	add deployment with vulnerable applications
	@kubectl apply -f deployments/lateral-movement-demo/lateral-movement-deployment-demo.yaml


setup-attack-scenario-02-post:
#	creating cluster
	@echo "Creating cluster for Scenario 2...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/cilium-enabled-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."

#	intalling cilium
	@echo "Installing Cilium...";
	@kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.9/install/kubernetes/quick-install.yaml
	@echo "";

# 	installing cilium hubble
	@echo "Installing Cilium Hubble..."
	@kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.9/install/kubernetes/quick-hubble-install.yaml

# 	add deployment with vulnerable applications
	@kubectl apply -f deployments/lateral-movement-demo/lateral-movement-deployment-demo-secured.yaml

# ---------------------------------------------------------------------------

setup-attack-scenario-03-falco-pre:
#	creating cluster
	@echo "Creating cluster for Scenario 3 with Falco...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/falco-cluster-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."

setup-attack-scenario-03-falco-post:
#	creating cluster
	@echo "Creating cluster for Scenario 3 with Falco...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/falco-cluster-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."

#	intalling Falco with rules for CV-2020-8554
	@helm repo add falcosecurity https://falcosecurity.github.io/charts
	@helm repo update
	@falco/rules2helm falco/cve-2020-8554/cve-2020-8554-rules.yaml > falco/cve-2020-8554/cve-2020-8554-helm-rules.yaml
	@helm install falco \
		-f falco/cve-2020-8554/cve-2020-8554-helm-rules.yaml \
		falcosecurity/falco
	@echo "";
	@echo "Done..."

# --set auditLog.enabled=true \
# --set falco.jsonOutput=true \
# --set falco.httpOutput.enabled=true \

# -------------

setup-attack-scenario-03-opa-gatekeeper-pre:
#	creating cluster
	@echo "Creating cluster for Scenario 3 with Gatekeeper...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/secured-cluster-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."
	@echo "Done..."

setup-attack-scenario-03-opa-gatekeeper-post:
#	creating cluster
	@echo "Creating cluster for Scenario 3 with Gatekeeper...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/secured-cluster-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."

#	intalling OPA Gatekeeper and constraints
#	@kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.5/deploy/gatekeeper.yaml
	@kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
	@echo "Sleeping before continuing creating resources...";
	@sleep 3;
	@kubectl apply -f opa/external-ip/template.yaml
	@sleep 3;
	@kubectl apply -f opa/external-ip/samples/allowed-ip/constraint.yaml
	@echo "";
	@echo "Done..."

# ---------------

setup-attack-scenario-03-admission-controllers-pre:
#	creating cluster
	@echo "Creating cluster for Scenario 3 with Admission Controllers...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/admission-controllers-cluster-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."
	@echo "Done..."

setup-attack-scenario-03-admission-controllers-post:
#	creating cluster
	@echo "Creating cluster for Scenario 3 with Admission Controllers...";
	@kind create cluster --name tfm-k8s --config $(ROOTDIR)/kind/configs/admission-controllers-cluster-config.yaml --retain
	@kubectl config set-context kind-tfm-k8s
	@echo "";
	@echo "Cluster created."

#	deploying Admission Controllers for invalid external IPs
	@echo "";
	@echo "Deploying Admission Controllers for this scenario"
	@kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.1/cert-manager.yaml
	@kubectl create ns cattle-externalip-system
	@sleep 5;
# 	https://github.com/rancher/externalip-webhook/blob/master/chart/README.md
	@helm install rancher-external-ip-webhook \
		rancher-chart/rancher-external-ip-webhook \
		--namespace cattle-externalip-system \
		--set allowedExternalIPCidrs="203.0.113.0/32"
	@echo "Sleeping before checking if the webhook is ready";
	@sleep 5;
	@kubectl --namespace=cattle-externalip-system get pods -l "app=rancher-external-ip-webhook,release=rancher-external-ip-webhook"
	@echo "Done";

# ---------------------------------------------------------------------------

sync-material-adjunto:
# 	copy latest version of file used for cluster vulnerable configuration
	@echo "Saving vulnerable KinD cluster configuration...";
	@cp kind/configs/vulnerable-cluster-config.yaml ../material-adjunto/kind/configs/

# 	copy latest version of Kubernetes Attack Matrix spreadsheets
	@echo "Saving latest version of support spreadsheets...";
	@gdrive export -f --mime application/vnd.openxmlformats-officedocument.spreadsheetml.sheet 137oKwyKXy67m58CIieDuvnG2EieTbETF8IbV3wd-HNg
	@gdrive export -f --mime application/vnd.openxmlformats-officedocument.spreadsheetml.sheet 1IOWILRuTKyZK77c7FeNTJPdlpDk_8Dn9OdFfm76tkhA
	@mv *.xlsx ../material-adjunto/kubernetes-attack-matrix/
	@echo "";

# 	copy latest version of thesis defense presentation
	@echo "Saving latest version of thesis presentation slides...";
	@gdrive export -f --mime application/pdf 1aOJZrzaAGcvGCUrw12tCLc0MOXI0AWx-KvMJjBrtejA
	@gdrive export -f --mime application/vnd.oasis.opendocument.presentation 1aOJZrzaAGcvGCUrw12tCLc0MOXI0AWx-KvMJjBrtejA
	@gdrive export -f --mime application/vnd.openxmlformats-officedocument.presentationml.presentation 1aOJZrzaAGcvGCUrw12tCLc0MOXI0AWx-KvMJjBrtejA
	@mv *.odp ../material-adjunto/transparencias-defensa/
	@mv *.pptx ../material-adjunto/transparencias-defensa/
	@mv *.pdf ../material-adjunto/transparencias-defensa/
	@echo "";

#	copy latest version of files for blue team and read team audits
	@echo "Saving latest version of config files for Blue and Red team audits";
	@cp ../tools/aquasecurity/kube-bench/job-master.yaml ../material-adjunto/audit/blue-team/
	@cp ../tools/aquasecurity/kube-bench/job-node.yaml ../material-adjunto/audit/blue-team/
	@cp ../tools/aquasecurity/kube-hunter/job.yaml ../material-adjunto/audit/red-team/
	@echo "";

#	------------------------ scenario 2 related data ------------------------

#	copy files for scenario 2
	@echo "Copying KinD config file and deployment manifests...";
	@cp kind/configs/cilium-enabled-config.yaml ../material-adjunto/attack-scenarios/02-lateral-movement/kind/
	@cp deployments/lateral-movement-demo/* ../material-adjunto/attack-scenarios/02-lateral-movement/deployment/
	@echo "";

#	Checkov audit log files
	@echo "Running Checkov analysis live...";
	@checkov -s -f deployments/lateral-movement-demo/lateral-movement-deployment-demo.yaml > ../material-adjunto/attack-scenarios/02-lateral-movement/checkov/checkov-audit-pre-mitigation.log
	@checkov -s -f deployments/lateral-movement-demo/lateral-movement-deployment-demo-secured.yaml > ../material-adjunto/attack-scenarios/02-lateral-movement/checkov/checkov-audit-post-mitigation.log
	@echo "";

#	Trivy audit log files
	@echo "Running Trivy analysis live...";
	@trivy ryuzakyl/guestbook-frontend-with-statusphp-vuln:1.0.0 > ../material-adjunto/attack-scenarios/02-lateral-movement/trivy/guestbook-frontend-with-statusphp-vuln-pre.log
	@trivy ryuzakyl/guestbook-frontend-with-statusphp-vuln:2.0.0 > ../material-adjunto/attack-scenarios/02-lateral-movement/trivy/guestbook-frontend-with-statusphp-vuln-post.log
	@trivy lizrice/shellshockable:0.1.0 > ../material-adjunto/attack-scenarios/02-lateral-movement/trivy/shellshockable-pre.log
	@trivy lizrice/shellshockable:0.3.0 > ../material-adjunto/attack-scenarios/02-lateral-movement/trivy/shellshockable-post.log
	@echo "";

#	polaris folder setup
	@echo "Saving Polaris related data...";
	@echo "Polaris related data is taken directly from the Dashboard service." > ../material-adjunto/attack-scenarios/02-lateral-movement/polaris/README.md
	@echo "";

#	copying network policy files
	@echo "Copying Cilium and Generic Network Policies...";
	@cp -r network-policies/lateral-movement-demo/* ../material-adjunto/attack-scenarios/02-lateral-movement/network-policies/
	@echo "";

#	------------------------ scenario 3 related data ------------------------

#	creating folders
	@mkdir -p ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554
	@mkdir -p ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/kind
	@mkdir -p ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/services
	@mkdir -p ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/admission-controllers
	@mkdir -p ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/opa-gatekeeper
	@mkdir -p ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/falco

#	copy kind configurations
	@cp kind/configs/admission-controllers-cluster-config.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/kind/
	@cp kind/configs/secured-cluster-config.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/kind/
	@cp kind/configs/falco-cluster-config.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/kind/

#	copy test services manifests
	@cp admission-controllers/externalip-webhook/example_allowed.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/services/
	@cp admission-controllers/externalip-webhook/example_disallowed.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/services/
	@echo "";

#	copy admission controllers related files
	echo "No files related to this approach" ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/admission-controllers/README.md

#	copy opa gatekeeper related files
	cp opa/external-ip/template.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/opa-gatekeeper/
	cp opa/external-ip/samples/allowed-ip/constraint.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/opa-gatekeeper/

#	copy falco related files
	@cp falco/rules2helm ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/falco/
	@cp falco/cve-2020-8554/cve-2020-8554-rules.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/falco/
	@cp falco/cve-2020-8554/cve-2020-8554-helm-rules.yaml ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/falco/
	@cp -r falco/cve-2020-8554/audit ../material-adjunto/attack-scenarios/03-man-in-the-middle-via-cve-2020-8554/falco/

#	------------------------ start of syncing process ------------------------

#	syncronize local 'material-adjunto' folder with Drive version
	@echo "Performing syncing with remote Drive folder...";
	@gdrive sync upload --keep-local --delete-extraneous ../material-adjunto 13loIUB0MFXO38_bwO38c_POiPfWMIoWX
	@echo "";

#	------------------------ end of syncing process ------------------------

#	end of sync process
	@echo "Done.";

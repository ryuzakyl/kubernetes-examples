# Setting up Falco for audit logs

From (https://falco.org/blog/detect-malicious-behaviour-on-kubernetes-api-server-through-audit-logs/#install-falco-and-falcosidekick-with-auditing-feature-enabled):

> We'll use Helm to install the Falco, so, there is an option that we can enable or disable the audit log feature called `auditLog.enabled`, once we set the value of the option as `true`, the embedded webserver will be started within the Falco to consume audit events from the port `8765` and behind `k8s-audit` endpoint.

What the previous explanation means is, i.e. the impact of such option is, that a `falco` service will be created with the `DaemonSet` pods as endpoints:

```console
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
falco        ClusterIP   10.96.240.111   <none>        8765/TCP   12m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    12m
```

In order to set the `auditLog.enabled` we must add the `--set auditLog.enabled=true` flag to the `helm install...` command. To verify that such configuration is in place, once `falco` service is `Ready`, we can do the following:

```console
$ helm get values falco | grep auditLog -A1

auditLog:
    enabled: true
```

# Setting up Falco for audit logs (WROKING SOLUTION)

> :memo: The final working solution for now, is the one on the video documented for scenario 03.

Tutorials of setting Falco up to detect threats:
* https://falco.org/blog/detect-malicious-behaviour-on-kubernetes-api-server-through-audit-logs/
* (Tutorial with audit backend) https://sysdig.com/blog/kubernetes-audit-log-falco/
* (Implementing a Webhook backend) https://dev.bitolog.com/implement-audits-webhook/

The `KinD` cluster config file is:
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  AdvancedAuditing: false
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      extraArgs:
        audit-log-path: "/tmp/audit/audit.log"
        audit-policy-file: "/tmp/audit/audit_policy.yaml"
      extraVolumes:
      - name: audit
        hostPath: /tmp/audit
        mountPath: /tmp/audit
  extraMounts:
  - hostPath: /dev
    containerPath: /dev
  - hostPath: ./tmp/audit
    containerPath: /tmp/audit
- role: worker
  extraMounts:
  - hostPath: /dev
    containerPath: /dev
- role: worker
  extraMounts:
  - hostPath: /dev
    containerPath: /dev
```

Another `KinD` config file example can be found [here](https://gist.github.com/developer-guy/68f0f021c68ab4cc1edbb25edc56e869).

To check if Falco picked the config up: we can run the following command:
```console
helm show values falcosecurity/falco | grep auditLog -A10
```

The previous command checked the configuration for `auditLog` in order to verify if the flag `--set auditLog.enabled=true` was correctly used during the configuration.

Once everything is deployed, we change the config of the `kube-apiserver` to backend service for audit logs with the following:

```console
# properly set the line 'server: http://<pod-ip>:8765/k8s-audit'
$ nano /tmp/audit/falco-kube-config

# edit the 'kube-apiserver' to support the service backend for audit logs
$ nano /tmp/kubernetes/manifests/kube-apiserver.yaml

# add the line
#     - --audit-webhook-config-file=/tmp/audit/falco-kube-config

# remove the line
#     - --audit-log-path=/tmp/audit/audit.log
```

The resulting `kubeconfig` file used as the audit backend would be this one:

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: http://<pod-ip>:8765/k8s-audit
  name: falco
contexts:
- context:
    cluster: falco
    user: ""
  name: default-context
current-context: default-context
preferences: {}
users: []
```


# Kubernetes Response Engine

* https://falco.org/blog/falcosidekick-kubeless/
* https://falco.org/blog/falcosidekick-openfaas/

# Tutorials

* https://sysdig.com/blog/mitre-privilege-escalation-falco/
* https://sysdig.com/blog/mitre-defense-evasion-falco/


# Other References
* (Getting started with Falco rules) https://sysdig.com/blog/getting-started-writing-falco-rules/
* https://falco.org/blog/falco-kind-prometheus-grafana/#install-prometheus
* https://sysdig.com/blog/unveil-processes-falco-cloud/
* https://github.com/developer-guy/awesome-falco
* https://github.com/developer-guy/awesome-falco#interactive-learning
* https://falco.org/blog/intro-k8s-security-monitoring/
* https://sysdig.com/blog/falco-helm-chart/
* https://falco.org/blog/falco-kind-prometheus-grafana/






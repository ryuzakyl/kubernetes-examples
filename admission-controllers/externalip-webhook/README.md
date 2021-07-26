created to address CVE-2020-8554

`externalip-webhook`, is a validating webhook which prevents services from using random external IPs. Cluster administrators can specify list of CIDRs allowed to be used as external IP by specifying `allowed-external-ip-cidrs` parameter. Webhook will only allow creation of services which doesn't require external IP or whose external IPs are within the range specified by the administrator.

The final squence of steps that ended up working is documented on the Makefile target `setup-attack-scenario-03-admission-controllers-post` and the Rancher Helm chart details can be found [here](https://github.com/rancher/externalip-webhook/blob/master/chart/README.md).

# Rancher tutorial

* https://github.com/rancher/externalip-Webhook
* (Helm chart tutorial) https://github.com/rancher/externalip-webhook/blob/master/chart/README.md
* My video about it

# AWS tutorial

* https://docs.aws.amazon.com/eks/latest/userguide/restrict-service-external-ip.html

> :memo: NOTE
> This tutorial works except for the part of the ImagePullBackoff error. I hadn't have time to check why this image couldn't be pulled. For future work, it might make sense to dig deeper on this issue.
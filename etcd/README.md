To download the `etcd` `etcdctl` binaries, we can download them from [here](https://github.com/etcd-io/etcd/releases/tag/v3.4.9).

Some documentation for the `etcdctl` CLI tool can be found here:
* https://github.com/etcd-io/etcd/blob/main/etcdctl/READMEv2.md
* curl http://3.98.5.136:2379/v2/keys/?recursive=true
* https://lzone.de/cheat-sheet/etcd
* https://etcd.io/docs/v3.2/op-guide/security/

To configure etcd when there are failures, etc., we can consult [this](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/) and [this](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#securing-communication).

## Using `etcdctl`

Listing etcd cluster member servers:
```console
ETCDCTL_API=3 etcdctl --endpoints <etcd-member-ip>:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  member list
```

Listing secrets:
```console
ETCDCTL_API=3 etcdctl --endpoints <etcd-member-ip>:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --prefix --keys-only
  get /
```

Making a backup of the database:
```console
ETCDCTL_API=3 etcdctl --endpoints <etcd-member-ip>:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --prefix --keys-only
  snapshot save snapshotdb
```

#!/usr/bin/env bash

MASTER_NODE_NAME='master-node'
WORKER_01_NAME='worker-node-01'
WORKER_02_NAME='worker-node-02'

echo "------------- Creating Multipass VMs -------------";
multipass launch --cpus 2 --mem 4G --disk 8G --name $MASTER_NODE_NAME --cloud-init multipass.yaml
multipass launch --cpus 1 --mem 3G --disk 6G --name $WORKER_01_NAME --cloud-init multipass.yaml
multipass launch --cpus 1 --mem 3G --disk 6G --name $WORKER_02_NAME --cloud-init multipass.yaml
echo "";
echo "";

echo "------------- Installing K3s on Master Node -------------";
MASTER_NODE_IP="$(echo "$(multipass info $MASTER_NODE_NAME | grep IPv4)" | tr -s ' ' | cut -d ' ' -f 2)"
k3sup install --ip $MASTER_NODE_IP --user ubuntu --k3s-extra-args "--cluster-init"
echo "";
echo "";

echo "------------- Joining Worker 01 to cluster -------------";
WORKER_01_IP="$(echo "$(multipass info $WORKER_01_NAME | grep IPv4)" | tr -s ' ' | cut -d ' ' -f 2)"
k3sup join --ip $WORKER_01_IP --user ubuntu --server-ip $MASTER_NODE_IP --server-user ubuntu
echo "";
echo "";

echo "------------- Joining Worker 02 to cluster -------------";
WORKER_02_IP="$(echo "$(multipass info $WORKER_02_NAME | grep IPv4)" | tr -s ' ' | cut -d ' ' -f 2)"
k3sup join --ip $WORKER_02_IP --user ubuntu --server-ip $MASTER_NODE_IP --server-user ubuntu
echo "";
echo "";

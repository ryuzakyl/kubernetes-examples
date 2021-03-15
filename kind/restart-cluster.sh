# https://discuss.kubernetes.io/t/restart-a-kind-cluster/5413/3
# https://github.com/kubernetes-sigs/kind/issues/148#issuecomment-464474528

CONTROL_PLANE=tfm-k8s-control-plane
WORKER_01=tfm-k8s-worker
WORKER_02=tfm-k8s-worker2

KIND_CONTAINERS=(
    $CONTROL_PLANE
    $WORKER_01
    $WORKER_02
)

for container in "${KIND_CONTAINERS[@]}"; do
    echo "Stopping node '$container'";
    docker container stop $container
done

echo "";
echo "-------------------------------------------------------";
echo "";

for container in "${KIND_CONTAINERS[@]}"; do
    echo "Starting node '$container'";
    docker start $container && docker exec $container sh -c 'mount -o remount,ro /sys; kill -USR1 1'
done

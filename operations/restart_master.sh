MASTER_SERVICES="etcd kube-apiserver kube-controller-manager kube-scheduler"
for service in ${MASTER_SERVICES}
do
    echo "--------------------------------------------------------------------------------"
    echo "Enable and start ${service}"
    echo "--------------------------------------------------------------------------------"
    sudo systemctl restart ${service}
    sudo systemctl is-active ${service}
done

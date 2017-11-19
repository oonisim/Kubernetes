NODE_SERVICES="kube-proxy kubelet docker flanneld"
for service in ${NODE_SERVICES}
do
    echo "--------------------------------------------------------------------------------"
    echo "Enable and start ${service}"
    echo "--------------------------------------------------------------------------------"
    sudo systemctl restart ${service}
    sudo systemctl is-active ${service}
done

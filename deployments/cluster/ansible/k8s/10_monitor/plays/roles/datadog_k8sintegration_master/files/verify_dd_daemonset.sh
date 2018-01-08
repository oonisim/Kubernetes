#!/usr/bin/env bash
# setup your kubelet with the --cadvisor-port=4194 option, or set port to 0 in this check's configuration to disable cAdvisor lookup.
# Update /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# #Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=0"
# Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=4194"
#
sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl create -f dd-agent.yaml
echo "wait 1 min for startup"
sleep 60

kubectl get daemonset -o wide
# Get the dd-agent pod running on the master.
# Get the Datadog agent service information.
POD=$(kubectl get pods -o wide | grep master | awk '{ print $1 }')
kubectl exec ${POD} /bin/bash service datadog-agent info

POD=$(kubectl get pods -o wide | grep node01 | awk '{ print $1 }')
kubectl exec ${POD} /bin/bash service datadog-agent info


# Using Docker
CID=$(docker ps | grep docker-dd-agent | awk '{ print $1 }')
docker exec -it ${CID} /bin/bash

# Inside docker
/etc/init.d/datadog-agent info -v
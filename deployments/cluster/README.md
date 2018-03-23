K8S deployment with kubeadm using Ansible
=========
Build a latest Kubernetes (K8S) non-HA cluster in AWS (CentOS) using kubeadm to explore K8S. There are multiple K8S/AWS deployment tools (kops, rancher, etc) and kubeadm is not yet production ready tool but it will be the one.

Supported Environment
------------
CentOS
RHEL
(Not yet Ubuntu/Debian)


Prerequisites
------------
### Target Nodes
* A Linux account is configured that can sudo without password. The account is used as the ansible remote_user to run the playbook tasks.
Use this user as K8S_ADMIN in the configurations (below).

### Ansible Master
* On Ansible master, ssh-agent or .ssh/config is configured to be able to SSH into the targets without providing pass phrase.

### AWS
AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variable have been set to those of the AWS account user to use.

### Datadog (optional)
DATADOG_API_KEY environment variable has been set to the Datadog account API_KEY.

Configurations

* k8s/deploy/02_os/roles/hosts/files/hosts has been provided with those IP and hostnames.
* k8s/conf/ansible/inventories/dev/group_vars/all/{env.yml and server.yml} have been configured.
* k8s/conf/ansible/inventories/dev/inventory/hosts inventory has been configured.
------------

Structure
------------

```
├── ansible
│   ├── aws
│   │   ├── ec2
│   │   │   ├── creation        <----- Create/setup AWS
│   │   │   └── operations      <----- Operate AWS
│   │   ├── conductor.sh
│   │   ├── player.sh
│   │   └── utilities
│   ├── k8s
│   │   ├── 01_prerequisite     <----- Pre-requisites to run Ansible e.g. Python requirements.
│   │   │   ├── plays           <----- Ansible playbooks
│   │   │   └── scripts         <----- Script to execute playbooks.
│   │   ├── 02_os               <----- OS level setup
│   │   │   ├── plays
│   │   │   └── scripts
│   │   ├── 03_k8s              <----- K8S deployment
│   │   │   ├── plays
│   │   │   └── scripts
│   │   ├── 10_monitor          <----- Datadog deployment
│   │   │   ├── plays
│   │   │   └── scripts
│   │   ├── 20_applications     <----- K8S applicaiton deployments
│   │   │   ├── plays
│   │   │   └── scripts
│   │   ├── _utility.sh
│   │   ├── conductor.sh
│   │   └── player.sh
│   ├── run_aws.sh
│   └── run_k8s.sh
├── conf
│   ├── ansible
│   │   ├── ansible.cfg
│   │   ├── callbacks
│   │   ├── inventories
│   │   └── vaultpass.encrypted
│   └── keys
└── tools
```


Preparation
------------

#### Environment variables

Set the variables appropriately before execution.

```
AWS_SECRET_ACCESS_KEY
AWS_ACCESS_KEY_ID
DATADOG_API_KEY
```

#### AWS
Test the AWS connectivity with Ansible dynamic inventory.
```
conf/ansible/inventories/aws/inventory/ec2.py
```

#### SSH
Make sure SSH can login to the target boxes during the executions.
```
eval $(ssh-agent)
ssh-add <key>
```

Execution
------------

#### AWS creation/setup
```
ansible/aws/ec2/creation/scripts/main.sh
```

#### K8S deployment

Module
1. 01_prerequisite
2. 02_os
3. 03_k8s
4. 10_monitor
5. 20_applications

```
ansible/k8s/<module>/scripts/main.sh
```

---

References
------------

#### kubeadm

* [Using kubeadm to Create a Cluster](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
* [Installing kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* [Troubleshooting kubeadm](https://kubernetes.io/docs/setup/independent/troubleshooting-kubeadm/)
* [GitHub Kubeadm Design Documents](https://github.com/kubernetes/kubeadm/tree/master/docs/design)
* [How kubeadm Initializes Your Kubernetes Master](https://www.ianlewis.org/en/how-kubeadm-initializes-your-kubernetes-master)

#### Cloud providor

* [Creating a Custom Cluster from Scratch - Cloud Provider](https://kubernetes.io/docs/getting-started-guides/scratch/#cloud-provider)
> Kubernetes has the concept of a Cloud Provider, which is a module which provides an interface for managing TCP Load Balancers, Nodes (Instances) and Networking Routes.

* [Rancher Docs - Kubernetes - Cloud Providers](http://rancher.com/docs/rancher/latest/en/kubernetes/providers/)
* [K8S AWS Cloud Provider Notes](https://docs.google.com/document/d/17d4qinC_HnIwrK0GHnRlD1FKkTNdN__VO4TH9-EzbIY/edit)

Considerations
------------

#### Hostname
Make sure each node has correct hostname set and it can be resolved in all nodes. Otherwise there can be issues that K8S node cannot join the cluster although kubeadm join says success.

#### Disable swap

[kubeadm init --kubernetes-version=v1.8.0 fail with connection refuse for Get http://localhost:10255/healthz](https://github.com/kubernetes/kubernetes/issues/53333)
> As of release Kubernetes 1.8.0, kubelet will not work with enabled swap. You have two choices: either disable swap or add to kubelet flag to continue working with enabled swap.

#### POD Network CIDR Range
Make sure to provide the POD network CIDR range to kubeadm and it aligns with that specified in the Flannel manifest.

```
kubeadm init --pod-network-cidr=10.244.0.0/16
```

[Flannel manifest](https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml)
```
kind: ConfigMap
apiVersion: v1
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
  labels:
    tier: node
    app: flannel
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "type": "flannel",
      "delegate": {
        "isDefaultGateway": true
      }
    }
  net-conf.json: |
    {
      "Network": "10.244.0.0/16",  <-----
      "Backend": {
        "Type": "vxlan"
      }
    }
```

#### apiserver-advertise-address
Make sure to specify the correct IP. If to use hostname, make sure it will not be resolved to a NAT address in VM environments.

#### AWS Cloud Provider
Cloud provider needs to be specified to kubeadm at the cluster configuration. If not specified, it would require re-installing the cluster to use the feature (GitHub 57718).

```
kubeadm init --config kubeadm_config.yaml
```
Instead of using --cloud-provider=aws to kubeadm, use kubeadm configuration. --cloud-provider=aws used to be used but there are several reports it causes issues and the kubeadm init documentation does not specify it although the manifest part shows it.

```
kubeadm_config.yaml
kind: MasterConfiguration
apiVersion: kubeadm.k8s.io/v1alpha1
api:
  advertiseAddress: {{ APISERVER_ADVERTISE_ADDRESS }}
networking:
  podSubnet:        {{ K8S_SERVICE_ADDRESSES }}       <----- POD network CIDR 10.244.0.0/16
cloudProvider:      {{ K8S_CLOUD_PROVIDER }}          <----- aws
```

#### Cleanup / Reinstallation
kubeadm reset does not clean up completely. Need to manually delete directories/files and Pod network interfaces.
[Failed to setup network for pod \ using network plugins \"cni\": no IP addresses available in network: podnet; Skipping pod"](https://github.com/kubernetes/kubernetes/issues/39557)

```
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/*
rm -rf /etc/cni/
ifconfig cni0 down
ifconfig flannel.1 down
ifconfig docker0 down
ip link delete cni0
ip link delete flannel.1
```

#### cgroups
Make sure kubelet will be in the same cgroups of docker so that kubelet can talk with docker daemon.
```
kubelet --runtime-cgroups=<docker cgroup> --kubelet-cgroups <docker cgroup>
```

#### SELinux
For K8S pods to be able to access the host files, need to align or relabel the files, or need to configure POD security contexts. To avoid these steps, for this experimental K8s deployment, disable SELinux. DO NOT in real environments.

**/etc/sysconfig/selinux**
```
SELINUX=disabled
```

#### Firewalld
Turn off the firewalld as K8S uses iptables to re-route the access to services to the backend pods.
```
sudo systemctl --now disable firewalld
sudo systemctl stop firewalld
```

---

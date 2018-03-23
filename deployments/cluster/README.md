K8S deployment with kubeadm using Ansible
=========
Build a latest Kubernetes (K8S) non-HA cluster in AWS (CentOS) using kubeadm to explore K8S. There are multiple K8S/AWS deployment tools (kops, rancher, etc) and kubeadm is not yet production ready tool but it will be the one.

Supported Environment
------------
CentOS
RHEL

Structure
------------

```
.
├── README.md
├── conf
│   └── ansible <---- Ansible configuration directory
│      ├── ansible.cfg
│      └── inventories
│           └── aws
│               ├── group_vars  <---- Ansible parameters are isolated in group_vars for each environment
│               │   ├── all
│               │   │   ├── env.yml
│               │   │   ├── server.yml
│               │   │   ├── aws.yml
│               │   │   ├── kube_state_metrics.yml
│               │   │   ├── helm.yml
│               │   │   └── datadog.yml
│               │   ├── masters
│               │   └── workers
│               └── inventory
│                   ├── ec2.ini
│                   ├── ec2.py
│                   └── hosts
├── ansible  <---- Ansible Playbooks directory
│   ├── aws
│   │   ├── ec2
│   │   │   ├── creation
│   │   │   └── operations
│   │   ├── conductor.sh
│   │   └── player.sh
│   ├── k8s
│   │   ├── 01_prerequisite       <----- Prerequisite module (each module has the same structure)
│   │   │   ├── Readme.md         <----- Readme for the module
│   │   │   ├── plays
│   │   │   │   ├── roles
│   │   │   │   └── site.yml
│   │   │   └── scripts
│   │   ├── 02_os                 <----- OS module e.g. settup sysctl parameters.
│   │   ├── 03_k8s_setup          <----- K8S cluster setup module
│   │   ├── 04_k8s_configuration  <----- K8S configuration module
│   │   ├── 10_datadog            <----- Datadog monitoring module
│   │   ├── 20_applications       <----- Sample application module
│   │   ├── conductor.sh          <----- Utility conducting playbook execution.
│   │   └── player.sh             <----- Run ansible-playbook
│   ├── run_aws.sh          <---- One-off script to run all AWS setup
│   └── run_k8s.sh          <---- One-off script to run all K8S setup
└── tools
```



Preparations
------------
### Target Nodes
* A Linux account is configured that can sudo without password. The account is used as the ansible remote_user to run the playbook tasks.
Use this user as K8S_ADMIN in the configurations (below).

### Ansible Master

#### SSH
* On Ansible master, ssh-agent and/or .ssh/config is configured to be able to SSH into the targets without providing pass phrase.

```
eval $(ssh-agent)
ssh-add <key>
ssh <ansible remote_user>@<target> sudo ls  # no prompt for asking password
```

#### AWS
Environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY set to those of the AWS account user to use and test the connectivity with Ansible dynamic inventory.

```
conf/ansible/inventories/aws/inventory/ec2.py
```

#### Datadog (optional)
Environment variable DATADOG_API_KEY set to the Datadog account API_KEY.

Configurations
------------

#### Environment parameters
Parameters for an environment are all isolated in group_vars of the environment inventory.

```
.
├── conf
│   └── ansible
│      ├── ansible.cfg
│      └── inventories
│           └── aws
│               ├── group_vars
│               │   ├── all             <----- Configure properties in the 'all' group vars.
│               │   │   ├── env.yml
│               │   │   ├── server.yml
│               │   │   ├── aws.yml
│               │   │   ├── kube_state_metrics.yml
│               │   │   ├── helm.yml
│               │   │   └── datadog.yml
│               │   ├── masters
│               │   └── workers
│               └── inventory
│                   ├── ec2.ini
│                   ├── ec2.py
│                   └── hosts           <----- Get target node(s) using tag values set upon creating AWS env with script
```

---

Execution (AWS envioronment creation)
------------

#### AWS creation/setup
```
├── ansible
│   ├── aws
│   │   ├── ec2
│   │   │   ├── creation
│   │   │   └── operations
│   │   ├── conductor.sh
│   │   └── player.sh
│   ├── k8s
│   ├── run_aws.sh   <----- Run this script
│   └── run_k8s.sh
```


Execution (K8S cluster setup)
------------


#### K8S deployment
```
.
├── ansible
│   ├── k8s
│   │   ├── 01_prerequisite
│   │   ├── 02_os
│   │   ├── 03_k8s_setup
│   │   ├── 04_k8s_configuration
│   │   ├── 10_datadog
│   │   ├── 20_applications
│   │   ├── conductor.sh
│   │   └── player.sh
│   ├── run_aws.sh
│   └── run_k8s.sh   <----- Run this script
```

Alternatively, to run each module one by one.

```
ansible/k8s/<module>/scripts/main.sh or
ansible/k8s/<module>/scripts/main.sh aws <ansible remote_user>
```

Modules:
1. 01_prerequisite
2. 02_os
3. 03_k8s_setup
4. 04_k8s_configuration
5. 10_datadog
6. 20_applications

---

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

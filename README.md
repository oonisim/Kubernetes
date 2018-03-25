K8S deployment with kubeadm using Ansible
=========
Build a latest Kubernetes (K8S) non-HA cluster in AWS (CentOS or RHEL) using kubeadm to explore K8S. There are multiple K8S/AWS deployment tools (kops, rancher, etc) and kubeadm is not yet production ready tool but it will be the one.

<img src="https://github.com/oonisim/Kubernetes/blob/master/Images/AWS.png">


Structure
------------

### Overview

Ansible playbooks and inventories under this Git repository location.

```
.
├── cluster         <---- K8S cluster installation home (AWS+K8S)
│   ├── ansible     <---- Ansible playbook directory
│   │   ├── aws
│   │   │   ├── ec2
│   │   │   │   ├── creation         <---- Module to setup AWS
│   │   │   │   └── operations
│   │   │   ├── conductor.sh
│   │   │   └── player.sh
│   │   └── k8s
│   │       ├── 01_prerequisite      <---- Module to setup Ansible pre-requisites
│   │       ├── 02_os                <---- Module to setup OS to install K8S
│   │       ├── 03_k8s_setup         <---- Module to setup K8S cluster
│   │       ├── 04_k8s_configuration <---- Module to configure K8S after setup
│   │       ├── 10_datadog           <---- Module to setup datadog monitoring (option)
│   │       ├── 20_applications      <---- Module for sample applications
│   │       ├── conductor.sh         <---- Script to conduct playbook executions
│   │       └── player.sh            <---- Playbook player
│   ├── conf
│   │   └── ansible          <---- Ansible configuration directory
│   │       ├── ansible.cfg  <---- Configurations for all plays
│   │       └── inventories  <---- Each environment has it inventory here
│   │           ├── aws      <---- AWS/K8S environment inventory
│   │           └── template
│   └── tools
├── master      <---- K8S master node data for run_k8s.s created by run_aws.sh or update manally.
├── run.sh      <---- Run run_aws.sh and run_k8s.sh
├── run_aws.sh  <---- Run AWS setups
└── run_k8s.sh  <---- Run K8S setups
```

#### Module and structure

Module is a set of playbooks and roles to execute a specific task e.g. 03_k8s_setup is to setup a K8S cluster. Each module directory has the same structure having Readme, Plays, and Scripts.
```
03_k8s_setup/
├── Readme.md         <---- description of the module
├── plays
│   ├── roles
│   │   ├── common    <---- Common tasks both for master and workers
│   │   ├── master    <---- Setup master node
│   │   ├── pki       <---- Patch up K8S CA on master
│   │   ├── user      <---- Setup K8S administrative users on master
│   │   ├── worker    <---- Setup worker nodes
│   │   ├── helm      <---- Setup Helm package manager
│   │   └── dashboard <---- Setup K8S Dashboard
│   ├── site.yml
│   ├── masters.yml   <--- playbook for master node
│   └── workers.yml   <--- playbook for worker nodes
└── scripts
    └── main.sh       <---- script to run the module (each module can run separately/repeatedly)
```
---

Preparations
------------
### For AWS

Have AWS access key_id, secret, and an AWS SSH keypair PEM file. MFA should not be used (or make sure to establish a session before execution).

### On Ansible master host

#### AWS CLI
Install AWS CLI and set the environment variables.

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* EC2_KEYPAIR_NAME
* REMOTE_USER        <---- AWS EC2 user (centos for CentOs, ec2-user for RHEL)

#### Ansible
Have Ansible (2.4.1 or later) and Boto to be able to run AWS ansible features. If the host is RHEL/CentOS/Ubuntu, run below will do the job.

```
(cd ./cluster/ansible/k8s/01_prerequisite/scripts && setup.sh)
```

Test the Ansible dynamic inventory.
```
conf/ansible/inventories/aws/inventory/ec2.py
```

#### SSH
Configure ssh-agent and/or .ssh/config with the AWS SSH PEM to be able to SSH into the targets without providing pass phrase. Create a test EC2 instance and test.

```
eval $(ssh-agent)
ssh-add <AWS SSH pem>
ssh ${REMOTE_USER}@<EC2 server> sudo ls  # no prompt for asking password

```

#### Datadog (optional)
Create an Datadog trial account and set environment variable DATADOG_API_KEY to that Datadog [account API_KEY](https://app.datadoghq.com/account/settings#api). The Datadog module setup the monitors/metrics to verify that K8S is up and running, and can start monitoring and setup alerts right away.

#### Ansible inventory

et environment (or shell) variable TARGET_INVENTORY=aws. The variable identifies the Ansible inventory **aws**  (same with ENV_ID in env.yml) to use.

Let's try
------------

Run ./run.sh to run all at once, or go through the configurations and executions step by step below.

---

Configurations
------------

### Parameters

Parameters for an environment are all isolated in group_vars of the environment inventory. Go through the group_vars files to set values.

#### EC2_KEYPAIR_NAME

Set the AWS SSH keypair name to use to **EC2_KEYPAIR_NAME** as an enviornment variable and/or in aws.yml.

#### ENV_ID

ENV_ID in env.yml is used to tag the target environment and the tags are used to identify configuration items that belong to the enviornment, e.g. EC2 dynamic inventory hosts.

#### Master node information
Information of the master node instance. If run_aws.sh is used, it creates a file **master** which includs them and run_k8s.sh can use them. Otherwise set them in env.yml after having created the AWS instances.

* K8S_MASTER_HOSTNAME
* K8S_MASTER_NODE_IP

#### REMOTE_USER
Use the default Linux account (centos for CentOS EC2) that can sudo without password as the Ansible remote_user to run the playbooks If using another account, configure it and make sure it can sudo without password and configure .ssh/config.

#### K8S_ADMIN and LINUX_USERS
K8S_ADMIN user runs K8S operations once K8S is up. Set a name to be used as an account to K8S_ADMIN in server.yml. The account is creaated via LINUX_USERS in server.yml, and set the password in the corresponding field.  Use [mkpasswd as explained in Ansible document](http://docs.ansible.com/ansible/latest/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module).

```
.
├── conf
│   └── ansible
│      ├── ansible.cfg
│      └── inventories
│           └── aws
│               ├── group_vars
│               │   ├── all             <---- Configure properties in the 'all' group vars
│               │   │   ├── env.yml     <---- Enviornment parameters e.g. ENV_ID to identify and to tag configuration items
│               │   │   ├── server.yml  <---- Server parameters e.g. location of kubelet configuration file
│               │   │   ├── aws.yml     <---- e.g. AMI image id, volume type, etc
│               │   │   ├── helm.yml    <---- Helm package manager specifics
│               │   │   ├── kube_state_metrics.yml
│               │   │   └── datadog.yml
│               │   ├── masters         <---- For master group specifics
│               │   └── workers
│               └── inventory
│                   ├── ec2.ini
│                   ├── ec2.py
│                   └── hosts           <---- Target node(s) using tag values (set upon creating AWS env)
```

Executions
------------
Make sure the environment variables are set.

Environment variables:
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* EC2_KEYPAIR_NAME
* REMOTE_USER
* DATADOG_API_KEY (optional)

Set TARGET_INVENTORY=aws variable which identifies the Ansible inventory **aws**  (same with ENV_ID) to use.

### AWS

```
├── cluster
├── maintenance.sh
├── master
├── run.sh
├── run_aws.sh   <--- Run this script.
└── run_k8s.sh
```


### K8S
In the directory, run run_k8s.sh. If DATADOG_API_KEY is not set, the 10_datadog module will cause errors but will continue.

```
├── cluster
├── maintenance.sh
├── master       <---- Make sure master node information is set in this file
├── run.sh
├── run_aws.sh
└── run_k8s.sh   <---- Run this script
```

Alternatively, run each module one by one, and skip 10_datadog if not using.
```
pushd ansible/k8s/<module>/scripts && main.sh or
ansible/k8s/<module>/scripts/main.sh aws <ansible remote_user>
```

Modules are:
```
├── 01_prerequisite      <---- Module to setup Ansible pre-requisites
├── 02_os                <---- Module to setup OS to install K8S
├── 03_k8s_setup         <---- Module to setup K8S cluster
├── 04_k8s_configuration <---- Module to configure K8S after setup
├── 10_datadog           <---- Module to setup datadog monitoring (option)
├── 20_applications      <---- Module for sample applications
├── conductor.sh         <---- Script to conduct playbook executions
└── player.sh            <---- Playbook player
```


Test
------------
#### Guestbook appliaction.

The Ansible playbook of 20_applications shows the EXTERNAL-IP for the guestbook application.

```
"msg": [
    "NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                               PORT(S)        AGE       SELECTOR",
    "frontend   LoadBalancer   10.104.46.88   aa8886b1f2f0f11e8a4ec06dfe7a500c-1694803115.us-west-1.elb.amazonaws.com   80:32110/TCP   43s       app=guestbook,tier=frontend"
]
```
Access ht<span>tp://</span>EXTERNAL-IP and it should show the page:

<img src="https://github.com/oonisim/Kubernetes/blob/master/Images/app.gustbook.png" width="450">

#### Datadog

Login to the Datadog and check its [dashboard](https://app.datadoghq.com/screen/integration/86/kubernetes?tv_mode=false).

<img src="https://github.com/oonisim/Kubernetes/blob/master/Images/datadog.k8s.png" width="250">

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
      "Network": "10.244.0.0/16",  <----
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
  podSubnet:        {{ K8S_SERVICE_ADDRESSES }}       <---- POD network CIDR 10.244.0.0/16
cloudProvider:      {{ K8S_CLOUD_PROVIDER }}          <---- aws
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

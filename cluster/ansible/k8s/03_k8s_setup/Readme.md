## Objective
Install K8S cluster using kubeadm

## How to run
./scripts/main.sh or
./scripts/main.sh <env|inventory> <ansible_remote_user>

args can specify ansible options such as --chech or -e variable=value

## Adding node
The bootstrap token and hash is saved when kubeadm init executed on master and passed to workers to run kubeadm join during the ansible playbook executions.

## Structure

```
.
├── Readme.md
├── plays
│   ├── roles
│   │   ├── common      <---- Common setup/configurations for master and workers. e.g. K8S package installation (including compatible docker).
│   │   ├── master      <---- Master node specific setup.
│   │   ├── pki         <---- Patch up K8S CA (master node specific).
│   │   ├── user        <---- Setup K8S administrative user. e.g. Create/sign client certificate for K8S access. (master node specific).
│   │   ├── dashboard   <---- K8S Dashboard (master node specific).
│   │   ├── helm        <---- Helm package manager (master node specific).
│   │   ├── worker      <---- Worker node specific setup/configuration. e.g. kubeadm join.
│   │   └── posttasks   <---- Not used now. In case post setup tasks such as clean up are required.
│   ├── site.yml
│   ├── masters.yml
│   └── workers.yml
└── scripts
    └── main.sh         <---- Run the ansible playbooks for K8S setup.
```


## Expected result

```
$ kubectl get nodes
NAME                                         STATUS    ROLES     AGE       VERSION
ip-172-31-1-43.us-west-1.compute.internal    Ready     <none>    16m       v1.9.6
ip-172-31-4-117.us-west-1.compute.internal   Ready     master    21m       v1.9.6
ip-172-31-4-61.us-west-1.compute.internal    Ready     <none>    16m       v1.9.6

$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                                                 READY     STATUS    RESTARTS   AGE
kube-system   etcd-ip-172-31-4-117.us-west-1.compute.internal                      1/1       Running   0          19m
kube-system   kube-apiserver-ip-172-31-4-117.us-west-1.compute.internal            1/1       Running   0          19m
kube-system   kube-controller-manager-ip-172-31-4-117.us-west-1.compute.internal   1/1       Running   0          19m
kube-system   kube-dns-6f4fd4bdf-97l9m                                             3/3       Running   0          20m
kube-system   kube-flannel-ds-6qg54                                                1/1       Running   0          20m
kube-system   kube-flannel-ds-ckpp9                                                1/1       Running   0          15m
kube-system   kube-flannel-ds-kw6l7                                                1/1       Running   0          15m
kube-system   kube-proxy-55p98                                                     1/1       Running   0          15m
kube-system   kube-proxy-ss8ft                                                     1/1       Running   0          15m
kube-system   kube-proxy-xftgv                                                     1/1       Running   0          20m
kube-system   kube-scheduler-ip-172-31-4-117.us-west-1.compute.internal            1/1       Running   0          19m
kube-system   kubernetes-dashboard-5bd6f767c7-spk7c                                1/1       Running   0          18m
kube-system   tiller-deploy-59d854595c-hrwwv                                       1/1       Running   0          18m
```
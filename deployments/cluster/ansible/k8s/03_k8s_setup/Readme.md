## Objective
Install K8S cluster using kubeadm

## How to run
./scripts/main.sh or ./scripts/main.sh <env|inventory> <ansible_remote_user>

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
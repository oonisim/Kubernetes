K8S (1.8) Installation Ansible
=========

Requirements
------------

* Servers provisioned with their hostnames and static IP addresses set.
* k8s/deploy/02_os/roles/hosts/files/hosts has been provided with those IP and hostnames.
* K8S_ADMIN user has been created who can sudo without password.
* k8s/conf/ansible/inventories/dev/group_vars/all/{env.yml and server.yml} have been configured.
* k8s/conf/ansible/inventories/dev/inventory/hosts inventory has been configured.

How to run
----------------
1. <module>/scripts/main.sh ${ENV} ${REMOTE_USER}

Note
----------------
Using root account to execute K8S, not a specific K8S admin account. To be fixed.
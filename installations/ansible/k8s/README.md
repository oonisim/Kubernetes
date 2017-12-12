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

1. k8s/deploy/01_ansible/scripts/main.sh ${ENV} ${REMOTE_USER}
2. k8s/deploy/02_os/scripts/main.sh      ${ENV} ${REMOTE_USER}
3. k8s/deploy/03_k8s/scripts/main.sh     ${ENV} ${REMOTE_USER}



    $ kubectl get nodes
    NAME      STATUS    ROLES     AGE       VERSION
    master    Ready     master    36m       v1.8.5
    node01    Ready     <none>    35m       v1.8.5
    node02    Ready     <none>    35m       v1.8.5
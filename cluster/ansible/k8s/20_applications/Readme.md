## Objective
Sample applications

## How to run
./scripts/main.sh or
./scripts/main.sh <env|inventory> <ansible_remote_user> <args>

args can specify ansible options such as --chech or -e variable=value

## Structure

```
.
├── Readme.md
├── plays
│   ├── roles
│   │   ├── guestbook             <----- k8s guestbook sample
│   │   ├── devops_k8s
│   │   ├── k8sbook
│   │   ├── kuard
│   │   ├── mongo                 <----- Mongo database 3 node cluster.
│   │   ├── mysql                 <----- Single MySQL
│   │   └── mysql_statefulset     <----- MySQL replication cluster
│   ├── masters.yml
│   └── site.yml
└── scripts
    └── main.sh

```

## Guestbook

[Example: Deploying PHP Guestbook application with Redis](https://kubernetes.io/docs/tutorials/stateless-application/guestbook)
At the creation, Ansible msg shows the EXTERNAL-IP. Access http://<EXTERNAL-IP> to use the application.

```
"msg": [
    "NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                               PORT(S)        AGE       SELECTOR",
    "frontend   LoadBalancer   10.104.46.88   aa8886b1f2f0f11e8a4ec06dfe7a500c-1694803115.us-west-1.elb.amazonaws.com   80:32110/TCP   43s       app=guestbook,tier=frontend"
]
```

![Guest Book](https://github.com/oonisim/Kubernetes/blob/master/Images/app.gustbook.png)

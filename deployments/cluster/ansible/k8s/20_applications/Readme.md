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
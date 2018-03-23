## Objective
Configure/reconfigure the K8S cluster. All the control pane configurations after K8S setup are to be done here.

## How to run
./scripts/main.sh or
./scripts/main.sh <env|inventory> <ansible_remote_user>

args can specify ansible options such as --chech or -e variable=value


## Structure

```
.
├── Readme.md
├── plays
│   ├── roles
│   │   ├── kubelet                   <---- Configure kubelet e.g. expose cAdvisor port.
│   │   └── kubernetes-rbac-policies  <---- Not used
│   ├── site.yml
│   ├── masters.yml
│   └── workers.yml
└── scripts
    └── main.sh
```

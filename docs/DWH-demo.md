# How to use Impala demo

```
$ ./get_cluster_ip.sh ${CLUSTER_CONF}
[Cloudera Manager]
Public IP: 13.113.180.45    Private IP: 10.0.0.155
CM URL: http://10.0.0.155:7180

[Nodes]
    worker    Public IP:     13.114.68.48    Private IP:        10.0.0.17
    worker    Public IP:    54.238.154.87    Private IP:       10.0.0.235
    master    Public IP:    13.115.129.96    Private IP:       10.0.0.247
    worker    Public IP:     13.114.58.95    Private IP:        10.0.0.32

[SSH Tunnel for Dynamic Port Forwarding]
ssh -i your-aws-sshkey.pem -D 8157 -q centos@13.113.180.45

SSH Tunnel to Impalad
ssh -i your-aws-sshkey.pem -L:21050:10.0.0.17:21050 -q centos@13.113.180.45
```

## Connecting to Impala from BI Tools

```
ssh -i your-aws-sshkey.pem -L:21050:10.0.0.17:21050 -q centos@13.113.180.45
```

This ssh connection creates a tunnel to Impala.
You can access to Impala using 127.0.0.1:21050 (local port forwarding) from your favorite BI tools.


## Users and Authentication

This script creates a non-secure cluster.
No users are created and no need to authenticate.

## EC2 Instances

If you change instance type, you can modify first section of `demo-dwh-c5-cluster.conf` or `demo-dwh-c6-cluster.conf`.

```
INSTANCE_TYPE_CM:        t2.xlarge    #vCPU 4, RAM 16G
INSTANCE_TYPE_MASTER:    t2.large     #vCPU 2, RAM 8G
INSTANCE_TYPE_WORKER:    r3.xlarge    #vCPU 4, RAM 30.5G, SSD 80Gx1

WORKER_NODE_NUM:         3            #Number of Worker Nodes
```
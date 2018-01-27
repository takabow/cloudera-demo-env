# Cloudera Data Science Workbench Demo Environment
Install scripts of Cloudera Data Science Workbench (CDSW) with CDH secure cluster on cloud.
This is for Demo purposes only. Don't use for production.

**Note: Please use the stable releases instead of master.** https://github.com/takabow/cdsw-demo-env/releases/

- These scripts install and deploy the following environment automatically.
  - Cloudera Data Science Workbench 1.2.1 (Trial)
    - Package Installation (not Parcel Installation)
  - Cloudera Enterprise 5.13.1 (Trial)
  - MIT-KDC
  - DNS configuration for CDSW (by Dnsmasq and xip.io)

- I only tested on following environments
  - AWS ap-northeast-1 (Tokyo) region
  - Cloudera Director 2.7.0 on Mac

## Requirement

- Cloudera Director 2.7.0
    - The simplest way to install Cloudera Director on Mac is here -> https://github.com/chezou/homebrew-cloudera
- AWS Environment
    - Setting up a VPC for Cloudera Director
    - Creating a security group for Cloudera Director
    - See https://www.cloudera.com/documentation/director/latest/topics/director_aws_setup_client.html

## How to use

1. You need to install Cloudera Director Server/Client on your localhost and accessible by localhost:7189

2. Copy `your-aws-info.conf.template` and create your own `your-aws-info.conf` with
- AWS_REGION
- AWS_SUBNET_ID
- AWS_SECURITY_GROUP
- KEY_PAIR
- AWS_AMI

3. Set `AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY` and run `cloudera-director bootstrap-remote` command. It takes about 30 minutes.

```
$ export AWS_ACCESS_KEY_ID=<your-aws-access-key>
$ export AWS_SECRET_ACCESS_KEY=<your-aws-secret>
$ cloudera-director bootstrap-remote cdsw-secure-cluster.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
```

**Note**
Only one cluster can be creted on the same network same time using this script.
Because `bootstrap-configure-network.sh` script using `nmap` tricks to identify the CM (KDC) node during the bootstrapping phase.
For the same reason, using this script in a large network (e.g. /16) is bad idea.

4. `./get_cluster_ip.sh <cluster.conf>` provides the connection information to the environment. See also the following Example section.

5. To terminate this environment, run `cloudera-director terminate-remote` command.

```
$ cloudera-director terminate-remote cdsw-secure-cluster.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
```

## Example
```
$ export AWS_ACCESS_KEY_ID=<your-aws-access-key>
$ export AWS_SECRET_ACCESS_KEY=<your-aws-secret>

$ cloudera-director bootstrap-remote cdsw-secure-cluster.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
Process logs can be found at /usr/local/Cellar/cloudera-director-client/2.6.0/libexec/logs/application.log
Plugins will be loaded from /usr/local/Cellar/cloudera-director-client/2.6.0/libexec/plugins
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=256M; support was removed in 8.0
Cloudera Director 2.6.0 initializing ...
Connecting to http://localhost:7189
Current user roles: [ROLE_READONLY, ROLE_ADMIN]
Found warnings in cluster configuration:
* WarningInfo{code=UNKNOWN_SERVICE_TYPE, properties={serviceType=KUDU}}
Configuration file passes all validation checks.
Creating a new environment...
Creating external database servers if configured...
Creating a new Cloudera Manager...
Creating a new CDH cluster...
* Requesting an instance for Cloudera Manager ............ done
* Installing screen package (1/1) .... done
* Running bootstrap script #1 (crc32: d69f328d) ........ done
* Waiting until 2017-10-30T19:36:15.802+09:00 for SSH access to [10.0.0.87, ip-10-0-0-87.ap-northeast-1.compute.internal, 13.112.200.168, ec2-13-112-200-168.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #2 (crc32: cb9d7c33) ....... done
* Waiting until 2017-10-30T19:36:15.825+09:00 for SSH access to [10.0.0.87, ip-10-0-0-87.ap-northeast-1.compute.internal, 13.112.200.168, ec2-13-112-200-168.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #3 (crc32: e61c80e1) ....... done
* Waiting until 2017-10-30T19:36:15.846+09:00 for SSH access to [10.0.0.87, ip-10-0-0-87.ap-northeast-1.compute.internal, 13.112.200.168, ec2-13-112-200-168.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #4 (crc32: cb3d995b) ....... done
* Waiting until 2017-10-30T19:36:15.867+09:00 for SSH access to [10.0.0.87, ip-10-0-0-87.ap-northeast-1.compute.internal, 13.112.200.168, ec2-13-112-200-168.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #5 (crc32: b9b25b8d) .......... done
* Waiting until 2017-10-30T19:36:15.893+09:00 for SSH access to [10.0.0.87, ip-10-0-0-87.ap-northeast-1.compute.internal, 13.112.200.168, ec2-13-112-200-168.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Inspecting capabilities of 10.0.0.87 .... done
* Normalizing 9f003cf7-8224-4684-9cc1-8a58bc59de09 ... done
* Installing ntp package (1/4) .... done
* Installing curl package (2/4) .... done
* Installing nscd package (3/4) .... done
* Installing gdisk package (4/4) ............................... done
* Resizing instance root partition ........ done
* Mounting all instance disk drives ......... done
* Running csd installation script on [10.0.0.87, ip-10-0-0-87.ap-northeast-1.compute.internal, 13.112.200.168, ec2-13-112-200-168.ap-northeast-1.compute.amazonaws.com] ....... done
* Waiting for new external database servers to start running ... done
* Installing repositories for Cloudera Manager ...... done
* Installing yum-utils package (1/3) .... done
* Installing cloudera-manager-daemons package (2/3) ..... done
* Installing cloudera-manager-server package (3/3) .... done
* Installing krb5-workstation package (1/1) .... done
* Installing cloudera-manager-server-db-2 package (1/1) .... done
* Starting embedded PostgreSQL database ...... done
* Starting Cloudera Manager server ... done
* Waiting for Cloudera Manager server to start .... done
* Setting Cloudera Manager License ... done
* Enabling Enterprise Trial ... done
* Configuring Cloudera Manager .... done
* Importing Kerberos admin principal credentials into Cloudera Manager ... done
* Deploying Cloudera Manager agent ... done
* Waiting for Cloudera Manager to deploy agent on 10.0.0.87 ..... done
* Setting up Cloudera Management Services .......... done
* Backing up Cloudera Manager Server configuration ....... done
* Inspecting capabilities of 10.0.0.87 ... done
* Running deployment post creation scripts ............. done
* Done ...
Cloudera Manager ready.
* Waiting for Cloudera Manager installation to complete .......... done
* Installing Cloudera Manager agents on all instances in parallel (20 at a time) .............................................................................................................................................................................................................................. done
* Creating CDH5 cluster using the new instances .... done
* Creating cluster: cdsw-secure-cluster ........ done
* Downloading parcels: CDH-5.13.0-1.cdh5.13.0.p0.29,KAFKA-3.0.0-1.3.0.0.p0.40,Anaconda-4.3.1,SPARK2-2.2.0.cloudera1-1.cdh5.12.0.p0.142354 ................................................................................................................................................ done
* Raising rate limits for parcel distribution to 256000KB/s with 5 concurrent uploads ... done
* Distributing parcels: KAFKA-3.0.0-1.3.0.0.p0.40,Anaconda-4.3.1,SPARK2-2.2.0.cloudera1-1.cdh5.12.0.p0.142354,CDH-5.13.0-1.cdh5.13.0.p0.29 ............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................... done
* Switching parcel distribution rate limits back to defaults: 51200KB/s with 25 concurrent uploads .... done
* Activating parcels: KAFKA-3.0.0-1.3.0.0.p0.40,Anaconda-4.3.1,SPARK2-2.2.0.cloudera1-1.cdh5.12.0.p0.142354,CDH-5.13.0-1.cdh5.13.0.p0.29 ................................................................................................................. done
* Creating cluster services ..... done
* Assigning roles to instances ..... done
* Automatically configuring services and roles ...... done
* Applying custom configurations of services .... done
* Configuring SENTRY database ... done
* Configuring Hive to use Sentry ... done
* Configuring HUE database ... done
* Creating role config groups, applying custom configurations and moving roles to created role config groups ... done
* Renaming role config group from DataNode Default Group to DATANODE worker Group Qe0czfXo ... done
* Configuring role config groups of type KUDU_TSERVER ... done
* Renaming role config group from NameNode Default Group to NAMENODE master Group TsyZul1m ... done
* Renaming role config group from SecondaryNameNode Default Group to SECONDARYNAMENODE master Group HMGzVnEK ... done
* Renaming role config group from ResourceManager Default Group to RESOURCEMANAGER master Group IyV17rNe ... done
* Renaming role config group from Master Default Group to KUDU_MASTER master Group Y7ecSorW ... done
* Enabling Kerberos ...................................................................................................................................................... done
* Preparing cluster cdsw-secure-cluster .... done
* Creating Hive Metastore Database ... done
* Creating Sentry Database ............................... done
* Calling firstRun on cluster cdsw-secure-cluster .... done
* Waiting for firstRun on cluster cdsw-secure-cluster ................................................................................................................................................................................................................................................................................................................................................... done
* Waiting for CD-FLUME-CMVDOBbE to start ..................................................... done
* Running instance post create scripts in parallel (20 at a time) .......................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................... done
* Shrinking away any more failed instances before continuing ... done
* Adjusting health thresholds to take into account optional instances. ................... done
* Done ...
Cluster ready.


$ ./get_cluster_ip.sh cdsw-secure-cluster.conf
[Cloudera Manager]
Public IP: 13.112.200.168    Private IP: 10.0.0.87
CM URL: http://10.0.0.87:7180

[Nodes]
    master    Public IP:    13.114.92.162    Private IP:       10.0.0.170
    worker    Public IP:     54.64.11.120    Private IP:       10.0.0.228
    worker    Public IP:    13.114.229.72    Private IP:       10.0.0.231
    worker    Public IP:    13.113.73.167    Private IP:       10.0.0.245
      cdsw    Public IP:   13.115.232.245    Private IP:        10.0.0.60

[CDSW]
CDSW URL: http://cdsw.10.0.0.60.xip.io

[SSH Tunnel for Dynamic Port Forwarding]
ssh -i your-aws-sshkey.pem -D 8157 -q centos@13.112.200.168

$ ssh -i your-aws-sshkey.pem -D 8157 -q centos@13.112.200.168
```

After above, you can access to http://cdsw.10.0.0.60.xip.io (IP 10.0.0.60 changes every time) from your web browser via SSH SOCKS Proxy (See https://www.cloudera.com/documentation/director/latest/topics/director_security_socks.html).

## How to use CDSW

- Access to CDSW from browser.
- Click "**Sign Up for a New Account**" and create a new account. This username doesn't relate to existing OS users or Kerberos principals. Therefore you can create any users.
    - e.g.)
    - Full Name: Demo User1
    - Username: user1
    - Email: user1@localhost.localdomain
    - Password: user1user1
- After logging in, authenticate against your cluster’s Kerberos KDC by going to the top-right dropdown menu and clicking **Settings** -> **Hadoop Authentication**. You can use the prepared principals `user1@HADOOP` and so on. Please read the following "Users and Authentication" section.
    - e.g.)
    - Principal: user1@HADOOP
    - Password: user1

## Users and Authentication

- OS and CDH users, principals
  - Demo users are created in the `postcreate-common-addusers-and-principals.sh` script.
  - By default, this script creates five demo users and principals.
  - username/password = `user1/user1`, `user2/user2`, `user3/user3`, `admin1/admin1`, `admin2/admin2`
  - `admin1` and `admin2` are in the same group `dba`.
  - The realm name creating by this script is `HADOOP`.
- Cloudera Manager/Cloudera Navigator
  - username/password = `admin/admin`
- CDSW users
  - You need to create CDSW user when you access to CDSW from your browser.

## CDSW w/ GPU Support

If you want to use GPU from CDSW, you can use `cdsw-gpu-secure-cluster.conf` instead of `cdsw-secure-cluster.conf`

```
$ cloudera-director bootstrap-remote cdsw-gpu-secure-cluster.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
```

By default, this conf boot up `p2.xlarge` instance.

You also need to create a custom CUDA-capable Engine Image.
https://www.cloudera.com/documentation/data-science-workbench/latest/topics/cdsw_gpu.html#custom_cuda_engine

I already built a sample CUDA-capable engine image. If you want to use [my image](https://hub.docker.com/r/takabow/cdsw-cuda/) (`takabow/cdsw-cuda:2`) instead of base engine, you can add the image by going to the top-right dropdown menu and clicking **Admin** -> **Engines** -> **Engine Images**.


For more details, please read the following document.
https://www.cloudera.com/documentation/data-science-workbench/latest/topics/cdsw_gpu.html

## EC2 Instances

If you change instance type, you can modify first section of `cdsw-secure-cluster.conf`.
But I think these instances are almost minimal.

```
INSTANCE_TYPE_CM:        t2.xlarge    #vCPU 4, RAM 16G
INSTANCE_TYPE_MASTER:    t2.large     #vCPU 2, RAM 8G
INSTANCE_TYPE_WORKER:    t2.large     #vCPU 2, RAM 8G
INSTANCE_TYPE_CDSW:      t2.2xlarge   #vCPU 8, RAM 32G

WORKER_NODE_NUM:         3            #Number of Worker Nodes

CDSW_DOCKER_VOLUME_NUM:  3
CDSW_DOCKER_VOLUME_GB:   200
```

## CDSW node

On the CDSW node, you can check the status of CDSW using `cdsw status`.
The following example is the status of `cdsw tatus` after installation finished.

```
$ sudo cdsw status
Cloudera Data Science Workbench Status

Service Status
docker: active
kubelet: active
nfs: active
Checking kernel parameters...

Node Status
NAME           STATUS    AGE       VERSION   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION               STATEFUL
ip-10-0-0-90   Ready     10m       v1.6.2    <none>        CentOS Linux 7 (Core)   3.10.0-514.16.1.el7.x86_64   true

GPUs present on nodes:
ip-10-0-0-90 ==>

System Pod status
NAME                                   READY     STATUS    RESTARTS   AGE       IP           NODE
etcd-ip-10-0-0-90                      1/1       Running   0          10m       10.0.0.90    ip-10-0-0-90
kube-apiserver-ip-10-0-0-90            1/1       Running   0          10m       10.0.0.90    ip-10-0-0-90
kube-controller-manager-ip-10-0-0-90   1/1       Running   0          10m       10.0.0.90    ip-10-0-0-90
kube-dns-3913472980-xp2c6              3/3       Running   0          10m       100.66.0.2   ip-10-0-0-90
kube-proxy-h6r54                       1/1       Running   0          10m       10.0.0.90    ip-10-0-0-90
kube-scheduler-ip-10-0-0-90            1/1       Running   0          10m       10.0.0.90    ip-10-0-0-90
node-problem-detector-v0.1-j9vg4       1/1       Running   0          9m        10.0.0.90    ip-10-0-0-90
weave-net-3np13                        2/2       Running   0          10m       10.0.0.90    ip-10-0-0-90

Cloudera Data Science Workbench Pod Status
NAME                                 READY     STATUS      RESTARTS   AGE       IP            NODE           ROLE
8l3yqddqq3bomzxx                     3/3       Running     0          2m        100.66.0.13   ip-10-0-0-90   console
cron-2108817090-tvzn2                1/1       Running     0          9m        100.66.0.6    ip-10-0-0-90   cron
db-3629635219-nd7nr                  1/1       Running     0          9m        100.66.0.5    ip-10-0-0-90   db
db-migrate-7af83a5-mjbbz             0/1       Completed   0          9m        100.66.0.4    ip-10-0-0-90   db-migrate
engine-deps-kqwv8                    1/1       Running     0          9m        100.66.0.3    ip-10-0-0-90   engine-deps
ingress-controller-328322188-8hvp5   1/1       Running     0          9m        10.0.0.90     ip-10-0-0-90   ingress-controller
livelog-1349091387-nmr0z             1/1       Running     0          9m        100.66.0.8    ip-10-0-0-90   livelog
reconciler-2327718847-fs39x          1/1       Running     0          9m        100.66.0.7    ip-10-0-0-90   reconciler
spark-port-forwarder-39gz4           1/1       Running     0          9m        100.66.0.9    ip-10-0-0-90   spark-port-forwarder
web-4124296242-6z1l7                 1/1       Running     0          9m        100.66.0.12   ip-10-0-0-90   web
web-4124296242-h5xml                 1/1       Running     0          9m        100.66.0.11   ip-10-0-0-90   web
web-4124296242-phq7g                 1/1       Running     0          9m        100.66.0.10   ip-10-0-0-90   web

Cloudera Data Science Workbench is ready!
```

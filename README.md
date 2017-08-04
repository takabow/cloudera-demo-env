# Cloudera Data Science Workbench Demo Environment
Install scripts of Cloudera Data Science Workbench (CDSW) with CDH secure cluster on cloud.
This is for Demo purposes only. Don't use for production.

- I only tested on following environments
  - AWS ap-northeast-1 (Tokyo) region
  - Cloudera Director 2.4 on Mac
  - Cloudera Enterprise 5.11 (installed automatically by this confs/scrips)
  - Kerberos
    - MIT-KDC (installed automatically by this confs/scrips)

## Requirement

- Cloudera Director 2.4
    - The simplest way to install Cloudera Director on Mac is here -> https://github.com/chezou/homebrew-cloudera
- AWS Environment 
    - Setting up a VPC for Cloudera Director
    - Creating a security group for Cloudera Director
    - See https://www.cloudera.com/documentation/director/latest/topics/director_aws_setup_client.html

## How to use

1. 
You need to install Cloudera Director Server/Client on your localhost and accessible by localhost:7189

2. Modify `your-aws-info.conf`
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

4. `./get_cluster_ip.sh` provides the connection information to the environment. See also the following Example section.

5. To terminate this environment, run `cloudera-director terminate-remote` command.

```
$ cloudera-director terminate-remote cdsw-secure-cluster.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
```

## Example
```
$ export AWS_ACCESS_KEY_ID=<your-aws-access-key>
$ export AWS_SECRET_ACCESS_KEY=<your-aws-secret>

$ cloudera-director bootstrap-remote cdsw-secure-cluster.conf --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
Process logs can be found at /opt/cloudera/director/cloudera-director-2.4.0/logs/application.log
Plugins will be loaded from /opt/cloudera/director/cloudera-director-2.4.0/plugins
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=256M; support was removed in 8.0
Cloudera Director 2.4.0 initializing ...
Connecting to http://localhost:7189
Current user roles: [ROLE_READONLY, ROLE_ADMIN]
Found warnings in cluster configuration:
* Unknown role type: GATEWAY for service type: SPARK2_ON_YARN in instance group: cdsw.
Configuration file passes all validation checks.
Creating a new environment...
Creating external database servers if configured...
Creating a new Cloudera Manager...
Creating a new CDH cluster...
* Requesting an instance for Cloudera Manager ......... done
* Installing screen package (1/1) .... done
* Running bootstrap script #1 (crc32: 870e227b) ....... done
* Waiting for SSH access to [10.0.0.192, ip-10-0-0-192.ap-northeast-1.compute.internal, 54.64.29.130, ec2-54-64-29-130.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #2 (crc32: f5aa6a87) ....... done
* Waiting for SSH access to [10.0.0.192, ip-10-0-0-192.ap-northeast-1.compute.internal, 54.64.29.130, ec2-54-64-29-130.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #3 (crc32: dedfcbfb) ....... done
* Waiting for SSH access to [10.0.0.192, ip-10-0-0-192.ap-northeast-1.compute.internal, 54.64.29.130, ec2-54-64-29-130.ap-northeast-1.compute.amazonaws.com], default port 22 .... done
* Running bootstrap script #4 (crc32: b9b25b8d) ....... done
* Waiting for SSH access to [10.0.0.192, ip-10-0-0-192.ap-northeast-1.compute.internal, 54.64.29.130, ec2-54-64-29-130.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Inspecting capabilities of 10.0.0.192 ... done
* Normalizing bdd4c330-bd57-47dc-acbd-141690b03783 .... done
* Installing ntp package (1/4) .... done
* Installing curl package (2/4) .... done
* Installing nscd package (3/4) .... done
* Installing gdisk package (4/4) ............................ done
* Resizing instance root partition ........ done
* Mounting all instance disk drives ........ done
* Running csd installation script on [10.0.0.192, ip-10-0-0-192.ap-northeast-1.compute.internal, 54.64.29.130, ec2-54-64-29-130.ap-northeast-1.compute.amazonaws.com] ....... done
* Installing repositories for Cloudera Manager ..... done
* Installing oracle-j2sdk1.7 package (1/4) .... done
* Installing yum-utils package (2/4) .... done
* Installing cloudera-manager-daemons package (3/4) .... done
* Installing cloudera-manager-server package (4/4) .... done
* Installing krb5-workstation package (1/1) .... done
* Installing cloudera-manager-server-db-2 package (1/1) .... done
* Starting embedded PostgreSQL database ..... done
* Starting Cloudera Manager server ... done
* Waiting for Cloudera Manager server to start .... done
* Setting Cloudera Manager License ... done
* Configuring Cloudera Manager ... done
* Importing Kerberos admin principal credentials into Cloudera Manager ... done
* Deploying Cloudera Manager agent ... done
* Waiting for Cloudera Manager to deploy agent on 10.0.0.192 ... done
* Setting up Cloudera Management Services ......... done
* Backing up Cloudera Manager Server configuration ...... done
* Inspecting capabilities of 10.0.0.192 ... done
* Running deployment post creation scripts ........ done
* Done ...
Cloudera Manager ready.
* Waiting for Cloudera Manager installation to complete ........ done
* Installing Cloudera Manager agents on all instances in parallel (20 at a time) ................................................................................................................................................................................................................................................................................................................... done
* Creating CDH5 cluster using the new instances .... done
* Creating cluster: demo-cluster ............................................................. done
* Downloading parcels: CDH-5.11.1-1.cdh5.11.1.p0.4,KUDU-1.3.0-1.cdh5.11.1.p0.27,KAFKA-2.1.1-1.2.1.1.p0.18,Anaconda-4.1.1,SPARK2-2.1.0.cloudera1-1.cdh5.7.0.p0.120904 ....................................................................................................................... done
* Raising rate limits for parcel distribution to 256000KB/s with 5 concurrent uploads ... done
* Distributing parcels: KUDU-1.3.0-1.cdh5.11.1.p0.27,KAFKA-2.1.1-1.2.1.1.p0.18,Anaconda-4.1.1,SPARK2-2.1.0.cloudera1-1.cdh5.7.0.p0.120904,CDH-5.11.1-1.cdh5.11.1.p0.4 ................................................................................................................................................................................................................................................................................................ done
* Switching parcel distribution rate limits back to defaults: 51200KB/s with 25 concurrent uploads .... done
* Activating parcels: KUDU-1.3.0-1.cdh5.11.1.p0.27,KAFKA-2.1.1-1.2.1.1.p0.18,Anaconda-4.1.1,SPARK2-2.1.0.cloudera1-1.cdh5.7.0.p0.120904,CDH-5.11.1-1.cdh5.11.1.p0.4 ............................................................................................................................ done
* Creating cluster services .... done
* Assigning roles to instances ....... done
* Automatically configuring services and roles .... done
* Applying custom configurations of services .... done
* Configuring HIVE database ... done
* Configuring SENTRY database ... done
* Configuring Hive to use Sentry ... done
* Configuring HUE database ... done
* Renaming role config group from DataNode Default Group to DATANODE worker Group KXRypCNa ... done
* Configuring role config groups of type KUDU_TSERVER ... done
* Configuring role config groups of type NAMENODE ... done
* Configuring role config groups of type SECONDARYNAMENODE ... done
* Configuring role config groups of type KUDU_MASTER ... done
* Enabling Kerberos .......................................................................................................................................................................... done
* Preparing cluster demo-cluster ... done
* Creating Hive Metastore Database ... done
* Creating Sentry Database ................................ done
* Calling firstRun on cluster demo-cluster ... done
* Waiting for firstRun on cluster demo-cluster ................................................................................................................................................................................................................................................................................................................................................................................................. done
* Starting Flume in cluster demo-cluster ... done
* Waiting for CD-FLUME-CSitDcgH to start .......................................................... done
* Running instance post create scripts in parallel (20 at a time) ................................................................................................................................................................................................................................................................................................................................................................................................... done
* Adjusting health thresholds to take into account optional instances. ....................... done
* Done ...
Cluster ready.


$ ./get_cluster_ip.sh 
[Cloudera Manager]
Public IP: 13.113.208.245    Private IP: 10.0.0.94
CM URL: http://10.0.0.94:7180

[Nodes]
      cdsw    Public IP:    54.178.199.60    Private IP:        10.0.0.84
    worker    Public IP:    52.68.245.202    Private IP:        10.0.0.41
    worker    Public IP:     52.199.42.62    Private IP:       10.0.0.120
    worker    Public IP:   13.113.243.105    Private IP:        10.0.0.99
    master    Public IP:     54.65.112.41    Private IP:       10.0.0.168

[CDSW]
CDSW URL: http://cdsw.10.0.0.84.xip.io

[SSH Tunnel for Dynamic Port Forwarding]
ssh -i your-aws-sshkey.pem -D 8157 -q centos@13.113.208.245


$ ssh -i your-aws-sshkey.pem -D 8157 -q centos@13.113.208.245
```

After above, you can access to http://cdsw.10.0.0.84.xip.io (IP 10.0.0.84 changes every time) from your web browser via SSH SOCKS Proxy (See https://www.cloudera.com/documentation/director/latest/topics/director_security_socks.html).

## Users

- OS and CDH users
  - Demo users are created in the `postcreate-common-addusers-and-principals.sh` script.
  - By default, this script creates three demo users.
  - username/password = `user1/user1`, `user2/user2`, `user3/user3`
- Cloudera Manager
  - username/password = `admin/admin`
- CDSW users
  - You need to create CDSW user when you access to CDSW from your browser.

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

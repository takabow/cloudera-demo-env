# Cloudera Demo Environment
Install scripts of Cloudera Demo cluster on the cloud environment.
This is for Demo purposes only. Don't use for production.

- These scripts install and deploy the following demo environment automatically.
  - Cloudera Data Science Workbench 1.3.0 (Trial) + Secure CDH Cluster (Cloudera Enterprise 5.14.0 Trial) + MIT-KDC + DNS configuration for CDSW (by Dnsmasq and xip.io)
    - `cdsw-secure-cluster.conf`
  - Secure CDH Cluster (Cloudera Enterprise 5.14.0 Trial) + MIT-KDC
    - `secure-cluster.conf`
  - Impala Demo Cluster (Cloudera Enterprise 5.14.0 Trial) + Sample data(airport data)
    - `impala-demo-cluster.conf`

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

## Creating demo env

1. You need to install Cloudera Director Server/Client on your localhost and accessible by localhost:7189

2. Copy `your-aws-info.conf.template` and create your own `your-aws-info.conf` with
- AWS_REGION
- AWS_SUBNET_ID
- AWS_SECURITY_GROUP
- KEY_PAIR
- AWS_AMI

3. Set `CLUSTER_CONF/AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY` and run `cloudera-director bootstrap-remote` command. It takes about 30 minutes.

```
$ export CLUSTER_CONF=<cluster-conf-you-use>
$ export AWS_ACCESS_KEY_ID=<your-aws-access-key>
$ export AWS_SECRET_ACCESS_KEY=<your-aws-secret>
$ cloudera-director bootstrap-remote ${CLUSTER_CONF} --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
```

**Note: Creating Secure Cluster**
Only one cluster can be creted on the same network same time when using secure cluster script.
Because `bootstrap-configure-network.sh` script using `nmap` tricks to identify the CM (KDC) node during the bootstrapping phase.
For the same reason, using this script in a large network (e.g. /16) is bad idea.

4. `./get_cluster_ip.sh <cluster.conf>` provides the connection information to the environment. See also the following Example section.

5. To terminate this environment, run `cloudera-director terminate-remote` command.

```
$ cloudera-director terminate-remote ${CLUSTER_CONF} --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
```

## Example
```
$ export AWS_ACCESS_KEY_ID=<your-aws-access-key>
$ export AWS_SECRET_ACCESS_KEY=<your-aws-secret>

$ cloudera-director bootstrap-remote ${CLUSTER_CONF} --lp.remote.username=admin --lp.remote.password=admin --lp.remote.hostAndPort=localhost:7189
Process logs can be found at /usr/local/Cellar/cloudera-director-client/2.7.0/libexec/logs/application.log
Plugins will be loaded from /usr/local/Cellar/cloudera-director-client/2.7.0/libexec/plugins
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=256M; support was removed in 8.0
Cloudera Director 2.7.0 initializing ...
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
* Installing screen package (1/1) ..... done
* Running bootstrap script #1 (crc32: 5e2d4d51) ....... done
* Waiting until 2018-01-27T10:45:22.034+09:00 for SSH access to [10.0.0.142, ip-10-0-0-142.ap-northeast-1.compute.internal, 54.65.50.23, ec2-54-65-50-23.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #2 (crc32: cb9d7c33) ......... done
* Running bootstrap script #3 (crc32: e61c80e1) ....... done
* Waiting until 2018-01-27T10:45:22.091+09:00 for SSH access to [10.0.0.142, ip-10-0-0-142.ap-northeast-1.compute.internal, 54.65.50.23, ec2-54-65-50-23.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #4 (crc32: cb3d995b) ....... done
* Waiting until 2018-01-27T10:45:22.116+09:00 for SSH access to [10.0.0.142, ip-10-0-0-142.ap-northeast-1.compute.internal, 54.65.50.23, ec2-54-65-50-23.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #5 (crc32: b9b25b8d) ....... done
* Waiting until 2018-01-27T10:45:22.143+09:00 for SSH access to [10.0.0.142, ip-10-0-0-142.ap-northeast-1.compute.internal, 54.65.50.23, ec2-54-65-50-23.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Inspecting capabilities of 10.0.0.142 .... done
* Normalizing bec25839-79c2-4404-9431-6dd8fdbb4aaf ... done
* Installing ntp package (1/5) .... done
* Installing curl package (2/5) .... done
* Installing nscd package (3/5) .... done
* Installing rng-tools package (4/5) .... done
* Installing gdisk package (5/5) ...................................... done
* Resizing instance root partition ........ done
* Mounting all instance disk drives ......... done
* Running csd installation script on [10.0.0.142, ip-10-0-0-142.ap-northeast-1.compute.internal, 54.65.50.23, ec2-54-65-50-23.ap-northeast-1.compute.amazonaws.com] ............ done
* Waiting for new external database servers to start running ... done
* Installing repositories for Cloudera Manager ....... done
* Installing yum-utils package (1/3) .... done
* Installing cloudera-manager-daemons package (2/3) .... done
* Installing cloudera-manager-server package (3/3) ..... done
* Installing krb5-workstation package (1/1) .... done
* Installing cloudera-manager-server-db-2 package (1/1) .... done
* Starting embedded PostgreSQL database ..... done
* Starting Cloudera Manager server ... done
* Waiting for Cloudera Manager server to start .... done
* Setting Cloudera Manager License ... done
* Enabling Enterprise Trial ... done
* Configuring Cloudera Manager ... done
* Importing Kerberos admin principal credentials into Cloudera Manager ... done
* Deploying Cloudera Manager agent ...... done
* Waiting for Cloudera Manager to deploy agent on 10.0.0.142 ...... done
* Setting up Cloudera Management Services .......... done
* Backing up Cloudera Manager Server configuration ...... done
* Inspecting capabilities of 10.0.0.142 ... done
* Running deployment post creation scripts ............. done
* Done ...
Cloudera Manager ready.
* Waiting for Cloudera Manager installation to complete ............ done
* Installing Cloudera Manager agents on all instances in parallel (20 at a time) ......................................................................................................................................................................................................................................................... done
* Creating CDH5 cluster using the new instances ...... done
* Creating cluster: cdsw-secure-cluster ........... done
* Downloading parcels: CDH-5.14.0-1.cdh5.14.0.p0.24,KAFKA-3.0.0-1.3.0.0.p0.40,Anaconda-4.3.1,SPARK2-2.2.0.cloudera2-1.cdh5.12.0.p0.232957 ............................................................................................................................................................ done
* Raising rate limits for parcel distribution to 256000KB/s with 5 concurrent uploads ... done
* Distributing parcels: KAFKA-3.0.0-1.3.0.0.p0.40,Anaconda-4.3.1,SPARK2-2.2.0.cloudera2-1.cdh5.12.0.p0.232957,CDH-5.14.0-1.cdh5.14.0.p0.24 ...................................................................................................................................................................................................................................................................................... done
* Switching parcel distribution rate limits back to defaults: 51200KB/s with 25 concurrent uploads ..... done
* Activating parcels: KAFKA-3.0.0-1.3.0.0.p0.40,Anaconda-4.3.1,SPARK2-2.2.0.cloudera2-1.cdh5.12.0.p0.232957,CDH-5.14.0-1.cdh5.14.0.p0.24 .................................................................. done
* Creating cluster services ...... done
* Assigning roles to instances ....... done
* Automatically configuring services and roles ...... done
* Applying custom configurations of services .... done
* Configuring HIVE database ... done
* Configuring SENTRY database ... done
* Configuring Hive to use Sentry ... done
* Configuring HUE database ... done
* Configuring OOZIE database ... done
* Creating role config groups, applying custom configurations and moving roles to created role config groups ... done
* Renaming role config group from DataNode Default Group to DATANODE worker Group iAkUADIN ... done
* Configuring role config groups of type NODEMANAGER ... done
* Renaming role config group from NodeManager Default Group to NODEMANAGER worker Group GRASHRUm ... done
* Renaming role config group from Tablet Server Default Group to KUDU_TSERVER worker Group xDb0l4tE ... done
* Renaming role config group from NameNode Default Group to NAMENODE master Group thn1VRCv ... done
* Configuring role config groups of type SECONDARYNAMENODE ... done
* Renaming role config group from SecondaryNameNode Default Group to SECONDARYNAMENODE master Group lxIjAI0X ... done
* Renaming role config group from ResourceManager Default Group to RESOURCEMANAGER master Group mqgs1lxS ... done
* Renaming role config group from Hive Metastore Server Default Group to HIVEMETASTORE master Group ZQyzYlmK ... done
* Configuring role config groups of type KUDU_MASTER ... done
* Enabling Kerberos ....................................................................................................................................................... done
* Preparing cluster cdsw-secure-cluster ..... done
* Creating Sentry Database .................................. done
* Calling firstRun on cluster cdsw-secure-cluster .... done
* Waiting for firstRun on cluster cdsw-secure-cluster .......................................................................................................................................................................................................................................................................................................................................................................... done
* Starting Flume in cluster cdsw-secure-cluster ... done
* Waiting for CD-FLUME-KlrjlJLn to start .................................................... done
* Running instance post create scripts in parallel (20 at a time) ...................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................... done
* Adjusting health thresholds to take into account optional instances. ..................................... done
* Done ...
Cluster ready.


$ ./get_cluster_ip.sh ${CLUSTER_CONF}
[Cloudera Manager]
Public IP: 54.65.50.23    Private IP: 10.0.0.142
CM URL: http://10.0.0.142:7180

[Nodes]
    master    Public IP:   13.112.189.230    Private IP:       10.0.0.124
    worker    Public IP:     54.248.19.28    Private IP:       10.0.0.243
    worker    Public IP:    54.238.98.138    Private IP:       10.0.0.157
    worker    Public IP:    13.230.218.46    Private IP:       10.0.0.108
      cdsw    Public IP:    13.230.82.112    Private IP:        10.0.0.44
```

## Connecting to Cloudera Manager

```
ssh -i your-aws-sshkey.pem -D 8157 -q centos@13.113.180.45
```

This ssh connection creates a SOCKS Proxy to your VPC.
You can access to Cloudear Manager, http://10.0.0.155:7180 - (IP 10.0.0.155 changes every time), from your web browser via SSH SOCKS Proxy (See https://www.cloudera.com/documentation/director/latest/topics/director_security_socks.html).

## How to use

- [How to use CDSW demo](/docs/cdsw-demo.md)
- [How to use Impala demo](/docs/impala-demo.md)
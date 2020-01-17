# Cloudera Demo Environment
Install scripts of Cloudera Demo cluster on the cloud environment.
This is for Demo purposes only. Don't use for production.

- These scripts install and deploy the following demo environment automatically.
  - CDH Cluster
    - `c5-base-cluster.conf` (Cloudera Enterprise 5.16.1 Trial)
    - `c6-base-cluster.conf` (Cloudera Enterprise 6.3.0 Trial)
  - CDH Secure Cluster + MIT-KDC
    - `c5-secure-cluster.conf`  (Cloudera Enterprise 5.16.1 Trial)
    - `c6-secure-cluster.conf`  (Cloudera Enterprise 6.3.0 Trial)
  - CDH HA Cluster
    - `c5-ha-cluster.conf`  (Cloudera Enterprise 5.16.1 Trial)
    - `c6-ha-cluster.conf`  (Cloudera Enterprise 6.3.0 Trial)
  - Cloudera Data Science Workbench (Secure) : CDH Secure Cluster + Cloudera Data Science Workbench + DNS configuration for CDSW
    - `c5-cdsw-secure-cluster.conf` (CDSW 1.6.0 Trial + Cloudera Enterprise 5.16.1 Trial)
    - `c6_3_2-cdsw1_6_1-secure.conf` (CDSW 1.6.1 Trial + Cloudera Enterprise 6.3.2 Trial)
  
  - Cloudera Data Science Workbench : CDH Cluster + Cloudera Data Science Workbench + DNS configuration for CDSW
    - `c6_3_2-cdsw1_6_1-unsecure.conf` (CDSW 1.6.1 Trial + Cloudera Enterprise 6.3.2 Trial)
 
  - Cloudera Data Science Workbench with GPU : CDH Cluster (with minimum features) + Cloudera Data Science Workbench with GPU settings + DNS configuration for CDSW
    - `c6_3_2-cdsw1_6_1-gpu-minimum.conf` (CDSW 1.6.1 Trial + Cloudera Enterprise 6.3.2 Trial)
  
- I only tested on following environments
  - AWS ap-northeast-1 (Tokyo) region
  - CentOS 7.4 (not tested on RHEL)
  - Cloudera Altus Director on Mac/Linux (See below for details)

## Requirement

- Cloudera Altus Director 6.3.0
    - Mac
        - The simplest way to install Cloudera Altus Director on Mac is here -> https://github.com/YoshiyukiKono/homebrew-cloudera
        - When you install Director this way, you can find application log at `/usr/local/Cellar/cloudera-director-server/6.3.0/libexec/logs/application.log`
    - Linux
        - https://www.cloudera.com/documentation/director/latest/topics/director_get_started_aws_install_dir_server.html
- AWS Environment
    - Setting up a VPC for Cloudera Altus Director
    - Creating a security group for Cloudera Altus Director
    - See https://www.cloudera.com/documentation/director/latest/topics/director_aws_setup_client.html

## Creating demo env

1. In this example, Cloudera Altus Director Server/Client is installed on your localhost and accessible by localhost:7189

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
Process logs can be found at /usr/local/Cellar/cloudera-director-client/6.0.0/libexec/logs/application.log
Plugins will be loaded from /usr/local/Cellar/cloudera-director-client/6.0.0/libexec/plugins
Cloudera Altus Director 6.0.0 initializing ...
Connecting to http://localhost:7189
Current user roles: [ROLE_READONLY, ROLE_ADMIN]
Creating a new environment...
Creating external database servers if configured...
Creating a new Cloudera Manager...
Creating a new CDH cluster...
* Requesting an instance for Cloudera Manager .......... done
* Installing screen package (1/1) .... done
* Running bootstrap script #1 (crc32: 4ac835dd) .... done
* Waiting until 2018-09-28T16:11:16.513+09:00 for SSH access to [10.0.0.50, ip-10-0-0-50.ap-northeast-1.compute.internal, 18.182.51.225, ec2-18-182-51-225.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #2 (crc32: cb9d7c33) .... done
* Waiting until 2018-09-28T16:11:16.541+09:00 for SSH access to [10.0.0.50, ip-10-0-0-50.ap-northeast-1.compute.internal, 18.182.51.225, ec2-18-182-51-225.ap-northeast-1.compute.amazonaws.com], default port 22 ... done
* Running bootstrap script #3 (crc32: e61c80e1) .... done
* Running bootstrap script #4 (crc32: cb3d995b) ..... done
* Running bootstrap script #5 (crc32: b9b25b8d) .... done
* Inspecting capabilities of 10.0.0.50 .... done
* Normalizing 9d5e5254-81eb-4b3c-879e-9548b9798a06 ... done
* Installing ntp package (1/5) ... done
* Installing curl package (2/5) .... done
* Installing nscd package (3/5) .... done
* Installing rng-tools package (4/5) .... done
* Installing gdisk package (5/5) ............. done
* Resizing instance root partition .... done
* Mounting all instance disk drives ... done
* Running csd installation script on [10.0.0.50, ip-10-0-0-50.ap-northeast-1.compute.internal, 18.182.51.225, ec2-18-182-51-225.ap-northeast-1.compute.amazonaws.com] ...... done
* Installing repositories for Cloudera Manager .... done
* Installing yum-utils package (1/3) ... done
* Installing cloudera-manager-daemons package (2/3) .... done
* Installing cloudera-manager-server package (3/3) .... done
* Installing krb5-workstation package (1/1) .... done
* Installing cloudera-manager-server-db-2 package (1/1) .... done
* Starting embedded PostgreSQL database .... done
* Starting Cloudera Manager server ... done
* Waiting for Cloudera Manager server to start ... done
* Configuring Cloudera Manager ... done
* Importing Kerberos admin principal credentials into Cloudera Manager .... done
* Deploying Cloudera Manager agent ... done
* Waiting for Cloudera Manager to deploy agent on 10.0.0.50 .... done
* Setting up Cloudera Management Services ...... done
* Backing up Cloudera Manager Server configuration .... done
* Inspecting capabilities of 10.0.0.50 ... done
* Running deployment post creation scripts ....... done
* Starting ... done
* Done ...
Cloudera Manager ready.
* Waiting for Cloudera Manager installation to complete ......... done
* Creating cluster: cdsw-c5-cluster ....................................................... done
* Starting parcel downloads ... done
* Installing Cloudera Manager agents, if required, on all instances in parallel (20 at a time) ............................................................................................................................................................................................................................................................................................... done
* Creating CDH5 cluster using the new instances .................................................................................................................................................................................................. done
* Distributing parcels: KAFKA-3.1.0-1.3.1.0.p0.35,CDSW-1.4.0.p1.431664,Anaconda-5.0.1,SPARK2-2.3.0.cloudera3-1.cdh5.13.3.p0.458809,CDH-5.15.1-1.cdh5.15.1.p0.4 ................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................. done
* Switching parcel distribution rate limits back to defaults: 51200KB/s with 25 concurrent uploads ... done
* Activating parcels: KAFKA-3.1.0-1.3.1.0.p0.35,CDSW-1.4.0.p1.431664,Anaconda-5.0.1,SPARK2-2.3.0.cloudera3-1.cdh5.13.3.p0.458809,CDH-5.15.1-1.cdh5.15.1.p0.4 .............................................................. done
* Creating cluster services ... done
* Assigning roles to instances ..... done
* Automatically configuring services and roles ...... done
* Applying custom configurations of services ... done
* Configuring Hive to use Sentry .... done
* Configuring HIVE database ... done
* Configuring OOZIE database ... done
* Creating role config groups, applying custom configurations and moving roles to created role config groups .... done
* Configuring role config groups of type NODEMANAGER ... done
* Configuring role config groups of type NAMENODE ... done
* Configuring role config groups of type HIVEMETASTORE ... done
* Enabling Kerberos ........................................................................................................................ done
* Creating Hive Metastore Database ... done
* Creating Sentry Database .......................... done
* Calling firstRun on cluster cdsw-c5-cluster ..... done
* Waiting for firstRun on cluster cdsw-c5-cluster ........................................................................................................................................................................................................................ done
* Starting Flume in cluster cdsw-c5-cluster ... done
* Waiting for CD-FLUME-kzdLrIVH to start ................................................. done
* Running instance post create scripts in parallel (20 at a time) ..................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................... done
* Shrinking away any more failed instances before continuing ... done
* Adjusting health thresholds to take into account optional instances. ........... done
* Done ...
Cluster ready.


$ ./get_cluster_ip.sh
--[cdsw-c5-cluster Environment]-----------------
[Cloudera Manager]
Public IP: 18.182.51.225    Private IP: 10.0.0.50
CM URL: http://10.0.0.50:7180

[Nodes]
     kafka    Public IP:     52.68.255.27    Private IP:        10.0.0.65
    worker    Public IP:    18.179.204.26    Private IP:        10.0.0.25
    worker    Public IP:    18.179.29.186    Private IP:         10.0.0.4
    worker    Public IP:    18.182.32.213    Private IP:        10.0.0.27
    master    Public IP:   52.199.175.192    Private IP:       10.0.0.234
      cdsw    Public IP:   13.231.171.232    Private IP:        10.0.0.62

[SSH Tunnel for Cloudera Manager]
ssh -i /Users/taka/configs/se-japan-keypair.pem -D 8157 -q centos@18.182.51.225

[CDSW]
CDSW URL: http://cdsw.10.0.0.62.xip.io

[SSH Tunnel for Cloudera Manager and Impala]
ssh -i /Users/taka/configs/se-japan-keypair.pem -L:21050:10.0.0.25:21050 -D 8157 -q centos@18.182.51.225
```

## Connecting to Cloudera Manager

```
ssh -i your-aws-sshkey.pem -D 8157 -q centos@18.182.51.225
```

This ssh connection creates a SOCKS Proxy to your VPC.
You can access to Cloudear Manager, http://10.0.0.50:7180 - (IP addresses change every time), from your web browser via SSH SOCKS Proxy (See https://www.cloudera.com/documentation/director/latest/topics/director_security_socks.html).

## How to use

- [How to use CDSW demo](/docs/cdsw-demo.md)
- [How to use DWH demo](/docs/DWH-demo.md)
- [How to use Secure Cluster](/docs/secure-demo.md)

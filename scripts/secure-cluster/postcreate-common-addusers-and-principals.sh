#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/instance-postcreate-addusers-and-principals.log 2>&1
date

# Add OS users
groupadd -g 1200 dba
groupadd -g 1000 admin
useradd -g admin -G dba -u 1000 admin
groupadd -g 1001 admin1
useradd -g admin -G dba -u 1001 admin1
groupadd -g 1002 admin2
useradd -g admin -G dba -u 1002 admin2
groupadd -g 1101 user1
useradd -g user1 -u 1101 user1
groupadd -g 1102 user2
useradd -g user2 -u 1102 user2
groupadd -g 1103 user3
useradd -g user3 -u 1103 user3


# Add principales
if [ -e /root/cm ]; then
    echo "addprinc -pw hdfs hdfs" | kadmin.local
    echo "addprinc -pw hive hive" | kadmin.local
    echo "addprinc -pw impala impala" | kadmin.local
    echo "addprinc -pw admin admin" | kadmin.local
    echo "addprinc -pw admin admin1" | kadmin.local
    echo "addprinc -pw admin admin2" | kadmin.local
    echo "addprinc -pw user1 user1" | kadmin.local
    echo "addprinc -pw user2 user2" | kadmin.local
    echo "addprinc -pw user3 user3" | kadmin.local
fi

# Add HDFS users
if [ -e /root/master ]; then
    klist
    echo "hdfs" | kinit hdfs
    klist
    hdfs dfs -mkdir /user/admin
    hdfs dfs -chown admin /user/admin
    hdfs dfs -mkdir /user/admin1
    hdfs dfs -chown admin /user/admin1
    hdfs dfs -mkdir /user/admin2
    hdfs dfs -chown admin /user/admin2
    hdfs dfs -mkdir /user/user1
    hdfs dfs -chown user1 /user/user1
    hdfs dfs -mkdir /user/user2
    hdfs dfs -chown user2 /user/user2
    hdfs dfs -mkdir /user/user3
    hdfs dfs -chown user3 /user/user3
fi


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
#groupadd -g 1101 user1
#useradd -g user1 -u 1101 user1
#groupadd -g 1102 user2
#useradd -g user2 -u 1102 user2
#groupadd -g 1103 user3
#useradd -g user3 -u 1103 user3

NUM_USER=16
for i in `seq 1 $NUM_USER`
do
    groupadd -g 110$i user$i
    useradd -g user$i -u 110$i user$i
done


# Add HDFS users
if [ -e /root/master ]; then
    sudo -u hdfs hdfs dfs -mkdir /user/admin
    sudo -u hdfs hdfs dfs -chown admin /user/admin
    sudo -u hdfs hdfs dfs -mkdir /user/admin1
    sudo -u hdfs hdfs dfs -chown admin /user/admin1
    sudo -u hdfs hdfs dfs -mkdir /user/admin2
    sudo -u hdfs hdfs dfs -chown admin /user/admin2
    #sudo -u hdfs hdfs dfs -mkdir /user/user1
    #sudo -u hdfs hdfs dfs -chown user1 /user/user1
    #sudo -u hdfs hdfs dfs -mkdir /user/user2
    #sudo -u hdfs hdfs dfs -chown user2 /user/user2
    #sudo -u hdfs hdfs dfs -mkdir /user/user3
    #sudo -u hdfs hdfs dfs -chown user3 /user/user3
    for i in `seq 1 $NUM_USER`
    do
        sudo -u hdfs hdfs dfs -mkdir /user/user$i
        sudo -u hdfs hdfs dfs -chown user$i /user/user$i
    done
fi

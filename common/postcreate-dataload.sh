#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/instance-postcreate-dataload 2>&1
date

mkdir /opt/data
cd /opt/data

yum -y install wget

# Downloading airlines data
wget https://ibis-resources.s3.amazonaws.com/data/airlines/airlines_parquet.tar.gz
tar xvzf airlines_parquet.tar.gz
sudo -u hdfs hdfs dfs -mkdir /tmp/airlines/
sudo -u hdfs hdfs dfs -put airlines_parquet/* /tmp/airlines/

wget https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat
sudo -u hdfs hdfs dfs -mkdir /tmp/airports
sudo -u hdfs hdfs dfs -put airports.dat /tmp/airports/

sudo -u hdfs hdfs dfs -chmod 777 /tmp/airlines /tmp/airports


# airport
sudo -u hive hive -e '''
CREATE EXTERNAL TABLE airports_csv (
id INT,
name STRING,
city STRING,
country STRING,
iata STRING,
icao STRING,
latitude DOUBLE,
longitude DOUBLE,
altitude INT,
timezone INT,
dst STRING,
tz_database STRING
)
ROW FORMAT SERDE "org.apache.hadoop.hive.serde2.OpenCSVSerde"
LOCATION "/tmp/airports";

CREATE EXTERNAL TABLE airlines_pq(
year INT,
month INT,
day INT,
dayofweek INT,
dep_time INT,
crs_dep_time INT,
arr_time INT,
crs_arr_time INT,
carrier STRING,
flight_num INT,
tail_num INT,
actual_elapsed_time INT,
crs_elapsed_time INT,
airtime INT,
arrdelay INT,
depdelay INT,
origin STRING,
dest STRING,
distance INT,
taxi_in INT,
taxi_out INT,
cancelled INT,
cancellation_code STRING,
diverted INT,
carrier_delay INT,
weather_delay INT,
nas_delay INT,
security_delay INT,
late_aircraft_delay INT
)
STORED AS PARQUET
LOCATION "/tmp/airlines/";

CREATE TABLE airports_local_pq STORED AS PARQUET AS SELECT * FROM airports_csv;
'''

IMPALA_NAME=`curl -s -u admin:admin http://${DEPLOYMENT_HOST_PORT}/api/v16/clusters/${CLUSTER_NAME}/services | grep "CD-IMPALA" | grep name | awk -F'"' '{print $4}'`
echo ${IMPALA_NAME}
IMPALAD_HOST_ID=`curl -s -u admin:admin http://${DEPLOYMENT_HOST_PORT}/api/v16/clusters/${CLUSTER_NAME}/services/${IMPALA_NAME}/roles | grep -A 8 '"type" : "IMPALAD"' | grep hostId | awk -F'"' 'NR==1{print $4}'`
echo ${IMPALAD_HOST_ID}
IMPALAD_IP_ADDR=`curl -s -u admin:admin http://${DEPLOYMENT_HOST_PORT}/api/v16/hosts | grep -A 1 ${IMPALAD_HOST_ID} | grep ipAddress | awk -F'"' 'NR==1{print $4}'`
echo ${IMPALAD_IP_ADDR}

sudo -u impala impala-shell -i ${IMPALAD_IP_ADDR} -q '''
INVALIDATE METADATA;

CREATE TABLE airlines_bi_local_pq STORED AS PARQUET AS SELECT *, concat(cast(year as string), lpad(cast(month as string),2,"0")) as date_yyyymm from airlines_pq;

COMPUTE STATS airlines_bi_local_pq;

COMPUTE STATS airports_local_pq;
'''

#!/bin/sh

# logging stdout/stderr
set -x
exec >> /root/postcreate-fix-invalid-config.log 2>&1
date

yum -y install epel-release
yum -y install jq

KUDU_SERVICE_NAME=$(curl -s -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services |  jq -r '.items[] | select( .type == "KUDU") | .name')
curl -s -X GET -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${KUDU_SERVICE_NAME}/roleConfigGroups/${KUDU_SERVICE_NAME}-KUDU_MASTER-BASE/config
curl -s -X PUT -H "Content-Type:application/json" -u ${CM_USERNAME}:${CM_PASSWORD} -d '{ "items": [{ "name": "fs_wal_dir", "value": "/data0/kudu/masterwal" },{ "name": "fs_data_dirs", "value": "/data0/kudu/master"}] }' http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${KUDU_SERVICE_NAME}/roleConfigGroups/${KUDU_SERVICE_NAME}-KUDU_MASTER-BASE/config
curl -s -X GET -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/clusters/${CLUSTER_NAME}/services/${KUDU_SERVICE_NAME}/roleConfigGroups/${KUDU_SERVICE_NAME}-KUDU_MASTER-BASE/config

exit 0

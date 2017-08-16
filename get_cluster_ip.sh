#!/bin/sh

# Clouder Director on localhost
CD_HOST_PORT="localhost:7189"
CD_USER_NAME="admin"
CD_USER_PASS="admin"

OS_USERNAME=`cat your-aws-info.conf | grep OS_USERNAME: | awk '{print $2}'`
KEY_PAIR=`cat your-aws-info.conf | grep KEY_PAIR: | awk '{print $2}'`

CLUSTER_CONF="$@"
if [ -n "$CLUSTER_CONF" ]; then
	CLUSTER_NAME=$(grep "^name:" $CLUSTER_CONF | awk '{print $2}')
	ENV_NAME=${CLUSTER_NAME}"%20Environment"
    #ENV_NAME=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/ | python2 -c 'import sys, json, urllib; print urllib.quote(json.load(sys.stdin)[0])'`
else
    CLUSTER_CONF="cdsw-secure-cluster.conf"
	CLUSTER_NAME=$(grep "^name:" $CLUSTER_CONF | awk '{print $2}')
	ENV_NAME=${CLUSTER_NAME}"%20Environment"
fi

DEPLOYMENT_NAME=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/ | python2 -c 'import sys, json, urllib; print urllib.quote(json.load(sys.stdin)[0])'`
CLUSTER_NAME=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/clusters/ | python -c 'import sys, json, urllib; print urllib.quote(json.load(sys.stdin)[0])'`

#Get CM IP Addrs on AWS
CM_PUBLIC_IPADDR=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/ |  python2 -c 'import sys, json; print json.load(sys.stdin)["managerInstance"]["properties"]["publicIpAddress"]'`
CM_PRIVATE_IPADDR=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/ |  python2 -c 'import sys, json; print json.load(sys.stdin)["managerInstance"]["properties"]["privateIpAddress"]'`

#Get Node IP Addrs on AWS
INS_IPADDRS=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/clusters/${CLUSTER_NAME} | python2 -c 'import sys, json;print "\n".join([i["virtualInstance"]["template"]["name"] +","+ i["properties"]["publicIpAddress"] +","+ i["properties"]["privateIpAddress"] for i in json.load(sys.stdin)["instances"]])'`

#Get An Impalad IP Addr on AWS
AN_IMPALD_IPADDR=`echo "${INS_IPADDRS}" | awk -F[,] '/worker/ {print $3}' | head -n1`

echo "[Cloudera Manager]"
echo "Public IP: ${CM_PUBLIC_IPADDR}    Private IP: ${CM_PRIVATE_IPADDR}"
echo "CM URL: http://${CM_PRIVATE_IPADDR}:7180"
echo ""

echo "[Nodes]"
echo "${INS_IPADDRS}" | awk -F[,] '{printf "%10s    Public IP: %16s    Private IP: %16s\n", $1, $2, $3}' 
echo ""

CDSW=`echo "${INS_IPADDRS}" | grep "cdsw"`
if [ -n "$CDSW" ]; then
   echo "[CDSW]"
   CDSW_PRIVATE_IPADDR=`echo $CDSW | awk -F[,] '{print $3}'`
   echo "CDSW URL: http://cdsw.${CDSW_PRIVATE_IPADDR}.xip.io" 
   echo ""
fi

echo "[SSH Tunnel for Dynamic Port Forwarding]"
echo "ssh -i ${KEY_PAIR} -D 8157 -q ${OS_USERNAME}@${CM_PUBLIC_IPADDR}"

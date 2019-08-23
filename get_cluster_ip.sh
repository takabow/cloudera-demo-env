#!/bin/sh

# Clouder Director on localhost
CD_HOST_PORT="localhost:7189"
CD_USER_NAME="admin"
CD_USER_PASS="admin"

AWS_KEY_PAIR=`cat your-aws-info.conf | grep KEY_PAIR: | awk '{print $2}'`
GCP_KEY_PAIR=`cat your-gcp-info.conf | grep KEY_PAIR: | awk '{print $2}'`

ENV_NAMES=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/ | python -c 'import sys, json; from six.moves.urllib.parse import quote; print("\n".join([quote(str(i)) for i in json.load(sys.stdin)]))'`

if [ -z "$ENV_NAMES" ]; then
    echo "No environment exists"
    exit;
fi

CLUSTER_CONF="$@"
if [ -n "$CLUSTER_CONF" ]; then
	CLUSTER_NAME=$(grep "^name:" $CLUSTER_CONF | awk '{print $2}')
	ENV_NAMES=${CLUSTER_NAME}"%20Environment"
fi

for ENV_NAME in $ENV_NAMES; do
    ENV_NAME_PRINT=`echo ${ENV_NAME} | python -c 'import sys, json; from six.moves.urllib.parse import unquote; print(unquote(sys.stdin.read()))'`

    echo "--[${ENV_NAME_PRINT}]-----------------"
    DEPLOYMENT_NAMES=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments`
    if [ "$DEPLOYMENT_NAMES" = "[ ]" ]; then
        echo "${ENV_NAME_PRINT} has no deployment."
        echo ""
        continue
    fi

    DEPLOYMENT_NAME=`echo ${DEPLOYMENT_NAMES} | python -c 'import sys, json; from six.moves.urllib.parse import quote; print(quote(json.load(sys.stdin)[0]))'`
    CLUSTER_NAME=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/clusters/ | python -c 'import sys, json; from six.moves.urllib.parse import quote; print(quote(json.load(sys.stdin)[0]))'`

    OS_USERNAME=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/ |  python -c 'import sys, json; print(json.load(sys.stdin)["credentials"]["username"])'`
    PROVIDOR=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/ |  python -c 'import sys, json; print(json.load(sys.stdin)["provider"]["type"])'`
    if [ "$PROVIDOR" = "aws" ]; then
        KEY_PAIR=${AWS_KEY_PAIR} 
    elif [ "$PROVIDOR" = "google" ]; then
        KEY_PAIR=${GCP_KEY_PAIR} 
    else
        KEY_PAIR="</path/to/your/private-key>"
    fi
    
    #Get CM IP Addrs on AWS
    CM_PUBLIC_IPADDR=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/ |  python -c 'import sys, json; print(json.load(sys.stdin)["managerInstance"]["properties"]["publicIpAddress"])'`
    CM_PRIVATE_IPADDR=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/ |  python -c 'import sys, json; print(json.load(sys.stdin)["managerInstance"]["properties"]["privateIpAddress"])'`

    #Get Node IP Addrs on AWS
    INS_IPADDRS=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/clusters/${CLUSTER_NAME} | python -c 'import sys, json;print("\n".join([i["virtualInstance"]["template"]["name"] +","+ i["properties"]["publicIpAddress"] +","+ i["properties"]["privateIpAddress"] for i in json.load(sys.stdin)["instances"]]))'`
    
    #Get Services
    SERVICES=`curl -s -u ${CD_USER_NAME}:${CD_USER_PASS} http://${CD_HOST_PORT}/api/v8/environments/${ENV_NAME}/deployments/${DEPLOYMENT_NAME}/clusters/${CLUSTER_NAME} | python -c 'import sys, json;print("\n".join([i["serviceName"] for i in json.load(sys.stdin)["services"]]))'`

    echo "[Cloudera Manager]"
    echo "Public IP: ${CM_PUBLIC_IPADDR}    Private IP: ${CM_PRIVATE_IPADDR}"
    echo "CM URL: http://${CM_PRIVATE_IPADDR}:7180"
    echo ""

    echo "[Nodes]"
    echo "${INS_IPADDRS}" | awk -F[,] '{printf "%10s    Public IP: %16s    Private IP: %16s\n", $1, $2, $3}' 
    echo ""

    echo "[SSH Tunnel for Cloudera Manager]"
    echo "ssh -i ${KEY_PAIR} -D 8157 -q ${OS_USERNAME}@${CM_PUBLIC_IPADDR}"
    echo ""

    CDSW=`echo "${INS_IPADDRS}" | grep "cdsw"`
    if [ -n "$CDSW" ]; then
    echo "[CDSW]"
    CDSW_PRIVATE_IPADDR=`echo $CDSW | awk -F[,] '{print $3}'`
    echo "CDSW URL: http://cdsw.${CDSW_PRIVATE_IPADDR}.xip.io" 
    echo ""
    fi

    IMPALA=`echo "${SERVICES}" | grep -i "impala"`
    if [ -n "$IMPALA" ]; then
        #Get An Impalad IP Addr on AWS
        AN_IMPALD_IPADDR=`echo "${INS_IPADDRS}" | awk -F[,] '/worker/ {print $3}' | head -n1`

        echo "[SSH Tunnel for Cloudera Manager and Impala]"
        echo "ssh -i ${KEY_PAIR} -L:21050:${AN_IMPALD_IPADDR}:21050 -D 8157 -q ${OS_USERNAME}@${CM_PUBLIC_IPADDR}"
        echo ""
    fi
done
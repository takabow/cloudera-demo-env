if [ $# -ne 1 ]; then
  echo "Usage: socks.sh <hostname>"
  exit 1
fi
echo $#
# nohup ssh -i <your-filename>.pem -CND 8157 centos@$1 &
ssh -i <your-filename>.pem -CND 8157 centos@$1 

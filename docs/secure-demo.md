# How to use Secure Cluster

You need to allow users to access database by `impala` user. Here is an example.
```
create role dba;
grant all on database default to dba;
grant role dba to group user1;
```

## CDSW1.6 Known Issues

### TLS/SSL

>Deployments using a custom Certificate Authority (signed by either their organisation's internal CA or a non-default CA) see HTTP Error 500 when attempting to launch the Terminal or Jupyter Notebook sessions from the Workbench

Workarounds are described below but it is not implemented in the script of this repository.

https://www.cloudera.com/documentation/data-science-workbench/latest/topics/cdsw_known_issues.html#security

```
sudo yum install wget
sudo wget https://www.cloudera.com/documentation/other/shared/ca-certificates.crt
sudo sh -c "cat /etc/ssl/certs/localhost.crt >> /etc/ssl/certs/ca-certificates.crt" 
```
TODO: Need to be scriptized to remove the last line of ca-certificates.crt and the first line of localhost.crt
```
sudo vi ca-certificates.crt 
```

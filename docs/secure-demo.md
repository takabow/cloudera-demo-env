# How to use Secure Cluster

You need to allow users to access database by `impala` user. Here is an example.
```
create role dab;
grant all on database default to dba;
grant role dba to group user1;
```

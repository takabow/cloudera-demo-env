#!/usr/bin/env python
# -*- coding: utf-8 -*-:q

from pyhocon import ConfigFactory
from pyhocon.exceptions import ConfigException
from argparse import ArgumentParser
import os

class color:
    OK = '\033[92m'
    WARN = '\033[93m'
    NG = '\033[91m'
    END_CODE = '\033[0m'

CLUSTER_CONFS = [
    "c5-base-cluster.conf",
    "c6-base-cluster.conf",
    "c5-secure-cluster.conf",
    "c6-secure-cluster.conf",
    "demo-dwh-c5-cluster.conf",
    "demo-dwh-c6-cluster.conf",
    "demo-iot-c5-cluster.conf",
    "demo-iot-c6-cluster.conf",
    "cdsw-c5-secure-cluster.conf"
]

PATHS = [
    'cloudera-manager.instance.bootstrapScriptsPaths',
    'cloudera-manager.postCreateScriptsPaths',
    'cluster.master.instance.bootstrapScriptsPaths',
    'cluster.worker.instance.bootstrapScriptsPaths',
    'cluster.cdsw.instance.bootstrapScriptsPaths',
    'cluster.kafka.instance.bootstrapScriptsPaths',
    'cluster.instancePostCreateScriptsPaths',
    'cluster.postCreateScriptsPaths'
]

def main():
    for cluster_conf in CLUSTER_CONFS:
        print("===== " + cluster_conf + " =====")
        conf = ConfigFactory.parse_file("../" + cluster_conf)

        default = []
        scripts = []

        for path in PATHS:
            scripts += conf.get(path, default)
        
        scripts = list(dict.fromkeys(scripts))
        
        print(scripts)
        
        for script in scripts:
            if not os.path.exists("../" + script):
                print(color.NG + "[NG] " + script + " doesn't exist" + color.END_CODE)

        print("")

if __name__ == '__main__':
    main()
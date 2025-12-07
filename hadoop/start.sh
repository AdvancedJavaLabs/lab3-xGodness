#!/bin/bash
set -e

service ssh start

NAMENODE_DIR=/opt/hadoop/data/namenode
if [ ! -d "$NAMENODE_DIR/current" ]; then
    hdfs namenode -format
fi

start-dfs.sh
start-yarn.sh

tail -f /dev/null

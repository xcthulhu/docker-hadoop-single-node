#!/bin/bash

/usr/sbin/sshd
su hduser -c "$HADOOP_HOME/sbin/start-dfs.sh"
su hduser -c "$HADOOP_HOME/sbin/start-yarn.sh"
tail -f $HADOOP_HOME/logs/*
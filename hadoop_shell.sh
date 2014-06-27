#!/bin/bash

HADOOP_PID=$(docker inspect --format {{.State.Pid}} hadoop)
sudo nsenter --target $HADOOP_PID --mount --uts --ipc --net --pid

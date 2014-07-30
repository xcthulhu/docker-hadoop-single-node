# The Dockerfiles: Single Node Apache Hadoop

This project is an attempt to create a common starting point for building a single node Hadoop image. The intent of this Dockerfile is to be a complete and functional system while also acting as a template that can be customized and expanded upon based on a user's need rather than to be an authority on how Hadoop should be configured.

## Building an Image

In the directory containing the Dockerfile run the following command:

```
# docker build --rm=true -t xcthulhu/hadoop-single-node .
```

## Running a Container

To start a container in daemon mode run the following command:

```
# HADOOP_ID=$(docker run -d -t xcthulhu/hadoop-single-node)
```

For debugging purposes you can view the Hadoop log tails by running a container in interactive mode:

```
# docker run -i -t xcthulhu/hadoop-single-node
```

## Persistent Storage

All non-config data files are stored in `/var/lib/hadoop/VERSION/data` within a container. The data files are broken down based on Hadoop version and then referenced by the `current` symlink. Hadoop 2.4.1 would be located at `/var/lib/hadoop/2.4.1/data` and then symlinked to `/var/lib/hadoop/current/data`. This is for maintainability and predictability purposes independent of the actual version of Hadoop used.

To persistently store Hadoop data files pass `/var/lib/hadoop` to the `-v` flag when running a container.

For more information regarding Docker volumes and persistent storage view the following articles:

* [Share Directories via Volumes](http://docs.docker.io/en/latest/use/working_with_volumes/)
* [Advanced Docker Volumes by Michael Crosby](http://crosbymichael.com/advanced-docker-volumes.html)

## Ports

This Dockerfile exposes the following ports:

HDFS

* 50070
* 50470
* 9000
* 50075
* 50475
* 50010
* 50020
* 50090

YARN

* 8088
* 8032
* 50060

By default Docker will not assign ports publicly. To manually assign ports use the `-p` flag when running a container. To assign them automatically use the `-P` flag.

For more information on Hadoop ports see the [Hortonworks Configuring Ports documentation](http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.9.1/bk_reference/content/reference_chap2.html).

For more information on Docker ports see the [Redirect Ports documentation](http://docs.docker.io/en/latest/use/port_redirection/).

## 64-bit Support

The implementation of Hadoop provided by this Dockerfile contains 64-bit support.

# nsenter instead of ssh

## What is nsenter?

`nsenter` is a small tool allowing to enter into namespaces. Technically, it can enter existing namespaces, or spawn a process into a new set of namespaces. "What are those namespaces you're blabbering about?" They are one of the essential constituants of containers.

## Installation

Running the following command installs nsenter in your host environment (where docker is run).

```
docker run -v /usr/local/bin:/target jpetazzo/nsenter
```

## Usage

```
./hadoop_shell.sh
```

Now you are inside the hadoop instance at the command line. The first step is to switch
from root to the hduser.

```
# su hduser
# cd /usr/local/hadoop
# bin/hdfs dfs -put LICENSE.txt /
# bin/hdfs dfs -ls /
Found 1 items
--rw-r--r--   1 hduser supergroup      13366 2014-06-27 19:41 /LICENSE.txt
# exit
```


# The Dockerfiles: Single Node Apache Hadoop

This project is an attempt to create a common starting point for building a single node Hadoop image. The intent of this Dockerfile is to be a complete and functional system while also acting as a template that can be customized and expanded upon based on a user's need rather than to be an authority on how Hadoop should be configured.

## Dependencies

One of the goals of this project is to build an image in as little time as possible. With this in mind a design decision was made to require all dependencies not managed by the base images's package manager be included locally in the ```packages``` directory. This will prevent the necessity of having to download hundreds of additional megabytes of software each time a build is attempted. This approach also has the added benefit of allowing you to obtain the necessary dependencies from sources you trust.

This Dockerfile has the following dependencies:

* [hadoop-2.3.0.tar.gz](http://www.apache.org/dyn/closer.cgi/hadoop/common/)
* [hadoop-common-release-2.3.0.tar.gz](https://github.com/apache/hadoop-common/releases)
* [protobuf-2.5.0.tar.gz](https://code.google.com/p/protobuf/downloads/detail?name=protobuf-2.5.0.tar.gz&can=2&q=)

All dependencies are expected to be in the gzip archive format and placed in the ```packages``` directory.

## Building an Image

In the directory containing the Dockerfile run the following command:

```$> docker build -t sticksnleaves/hadoop-single-node .```

## Running a Container

To start a container in daemon mode run the following command:

```$> $HADOOP_ID=$(docker run -d -t sticksnleaves/hadoop-single-node)```

For debugging purposes you can view the Hadoop log tails by running a container in interactive mode:

```$> docker run -i -t sticksnleaves/hadoop-single-node```

## Persistent Storage

All non-config data files are stored in ```/var/lib/hadoop/VERSION/data``` within a container. The data files are broken down based on Hadoop version and then referenced by the ```current``` symlink. Hadoop 2.3.0 would be located at ```/var/lib/hadoop/2.3.0/data``` and then symlinked to ```/var/lib/hadoop/current/data```. This is for maintainability and predictability purposes independent of the actual version of Hadoop used.

To persistently store Hadoop data files pass ```/var/lib/hadoop``` to the ```-v``` flag when running a container.

For more information regarding Docker volumes and persistent storage view the following articles:

* [Share Directories via Volumes](http://docs.docker.io/en/latest/use/working_with_volumes/)
* [Advanced Docker Valumes by Michael Crosby](http://crosbymichael.com/advanced-docker-volumes.html)

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

By default Docker will not assign ports publicly. To manually assign ports use the ```-p``` flag when running a container. To assign them automatically use the ```-P``` flag.

For more information on Hadoop ports see the [Hortonworks Configuring Ports documentation](http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.9.1/bk_reference/content/reference_chap2.html).

For more information on Docker ports see the [Redirect Ports documentation](http://docs.docker.io/en/latest/use/port_redirection/).
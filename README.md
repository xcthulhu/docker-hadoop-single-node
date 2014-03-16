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

Feel free to replace the image tag specified by ```-t``` to something relevant to your needs.

## Running a Container

Run the following command to start the container in daemon mode:

```$> $HADOOP_ID=$(docker run -d -P -t sticksnleaves/hadoop-single-node```)

By default the container will execute the [services/start-hadoop.sh](https://github.com/sticksnleaves/docker-hadoop-single-node/blob/master/services/start-hadoop.sh) script provided with this project. This script starts ```sshd```, HDFS and YARN services and tails all Hadoop logs.

For debugging purposes you can run the container in interactive mode to view the Hadoop log tails by running the following command:

```$> docker run -i -P -t sticksnleaves/hadoop-single-node```

If you'd rather execute something other than the default script run the following command:

```$> docker run -i -P -t sticksnleaves/hadoop-single-node /bin/bash```

Where ```/bin/bash``` is the command to execute (the above example will allow you to access the container's shell).

For perisstant storage pass ```/var/lib/hadoop``` to the ```-v``` flag to add a Docker volume:

```$> docker run -i -P -v /var/lib/hadoop -t sticksnleaves/hadoop-single-node```

For more information on how to manage Docker volumes and persistant storage [view their documentation](http://docs.docker.io/en/latest/use/working_with_volumes/). Also take a look at [Advanced Docker Volumes by Michael Crosby](http://crosbymichael.com/advanced-docker-volumes.html).
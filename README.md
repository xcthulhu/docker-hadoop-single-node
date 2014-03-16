# The Dockerfiles: Single Node Apache Hadoop

This project is an attempt to create a common starting point for building a single node Hadoop container. The intent of this Dockerfile is to be a complete and functional system while also acting as a template that can be customized and expanded upon based on a user's need rather than to be an authority on how Hadoop should be configured.

## Dependencies

One of the goals of this project is to build a container in as little time as possible. With this in mind a design decision was made to require all dependencies not managed by the base container's package manager be included locally in the ```packages``` directory. This will prevent the necessity of having to download hundreds of additional megabytes of software each time a build is attempted. This approach also has the added benefit of allowing you to obtain the necessary dependencies from sources you trust.

This Dockerfile has the following dependencies:

* [hadoop-2.3.0.tar.gz](http://www.apache.org/dyn/closer.cgi/hadoop/common/)
* [hadoop-common-release-2.3.0.tar.gz](https://github.com/apache/hadoop-common/releases)
* [protobuf-2.5.0.tar.gz](https://code.google.com/p/protobuf/downloads/detail?name=protobuf-2.5.0.tar.gz&can=2&q=)

All dependencies are expected to be in the gzip archive format and placed in the ```packages``` directory.
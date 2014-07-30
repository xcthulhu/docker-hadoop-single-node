#
# Copyright (c) 2014 Sticksnleaves & xcthulhu
#
# Apache Hadoop 2.4.1 single node install
#

FROM ubuntu:12.04
MAINTAINER Matthew Wampler-Doty

# Prepare the operating system
RUN apt-get update

# Install dependencies
RUN apt-get install -y llvm-gcc build-essential make cmake automake autoconf libtool zlib1g-dev

# Prepare fuse for JDK install
RUN apt-get install -y libfuse2
WORKDIR /tmp
RUN apt-get download fuse
RUN dpkg-deb -x fuse_* .
RUN dpkg-deb -e fuse_*
RUN echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN dpkg-deb -b . /fuse.deb
RUN dpkg -i /fuse.deb
RUN rm -r /tmp/fuse*

# Install Java dependencies
ENV JAVA_HOME /usr/lib/jvm/jdk
RUN apt-get install -y openjdk-7-jdk maven
RUN ln -s /usr/lib/jvm/java-7-openjdk-amd64 $JAVA_HOME

# Add hadoop user
RUN addgroup hadoop
RUN useradd -d /home/hduser -m -s /bin/bash -G hadoop hduser

# Setup Hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_DATA /var/lib/hadoop
RUN apt-get install -y wget
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-2.4.1/hadoop-2.4.1.tar.gz
RUN tar zxfv hadoop-2.4.1.tar.gz -C /usr/local
RUN ln -s /usr/local/hadoop-2.4.1 $HADOOP_HOME
RUN rm hadoop-2.4.1.tar.gz
RUN mkdir $HADOOP_HOME/logs
RUN mkdir -p $HADOOP_DATA/2.4.1/data
RUN mkdir -p $HADOOP_DATA/current/data
RUN ln -s $HADOOP_DATA/2.4.1/data $HADOOP_DATA/current/data

# Build protobuf
RUN wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
RUN tar zxfv protobuf-2.5.0.tar.gz
RUN cd protobuf-2.5.0 ; \
    ./configure --prefix=/usr/local ; \
    make ; \
    make install
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
RUN ldconfig
RUN protoc --version
RUN rm -r /tmp/protobuf-2.5.0/
RUN rm /tmp/protobuf-2.5.0.tar.gz

# Build Hadoop Common
RUN wget https://github.com/apache/hadoop-common/archive/release-2.4.1.tar.gz
RUN tar zxfv release-2.4.1.tar.gz
RUN ls -al hadoop-common-release-2.4.1/
RUN cd hadoop-common-release-2.4.1/hadoop-common-project/hadoop-common ; mvn package -X -Pnative -DskipTests
RUN mv $HADOOP_HOME/lib/native/libhadoop.a $HADOOP_HOME/lib/native/libhadoop32.a
RUN mv $HADOOP_HOME/lib/native/libhadoop.so $HADOOP_HOME/lib/native/libhadoop32.so
RUN mv $HADOOP_HOME/lib/native/libhadoop.so.1.0.0 $HADOOP_HOME/lib/native/libhadoop32.so.1.0.0
RUN cd hadoop-common-release-2.4.1/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib ; \
    mv libhadoop.a $HADOOP_HOME/lib/native/libhadoop.a ; \
    mv libhadoop.so $HADOOP_HOME/lib/native/libhadoop.so ; \
    mv libhadoop.so.1.0.0 $HADOOP_HOME/lib/native/libhadoop.so.1.0.0
RUN rm -r /tmp/hadoop-common-release-2.4.1/
RUN rm /tmp/release-2.4.1.tar.gz

# Export Hadoop environment variables
ENV PATH $PATH:$HADOOP_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /home/hduser/.bashrc
RUN echo "export HADOOP_HOME=$HADOOP_HOME" >> /home/hduser/.bashrc
RUN echo "export PATH=$PATH" >> /home/hduser/.bashrc
RUN echo "export HADOOP_MAPRED_HOME=$HADOOP_MAPRED_HOME" >> /home/hduser/.bashrc
RUN echo "export HADOOP_COMMON_HOME=$HADOOP_COMMON_HOME" >> /home/hduser/.bashrc
RUN echo "export HADOOP_HDFS_HOME=$HADOOP_HDFS_HOME" >> /home/hduser/.bashrc
RUN echo "export YARN_HOME=$YARN_HOME" >> /home/hduser/.bashrc

# Configure SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN su hduser -c "ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''"
RUN su hduser -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
ADD config/ssh_config /home/hduser/.ssh/config 

# Configure HDFS
ADD config/core-site.xml /tmp/core-site.xml
ADD config/hdfs-site.xml /tmp/hdfs-site.xml
ADD config/hadoop-env.sh /tmp/hadoop-env.sh
RUN rm $HADOOP_HOME/etc/hadoop/core-site.xml
RUN rm $HADOOP_HOME/etc/hadoop/hdfs-site.xml
RUN rm $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
RUN mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
RUN mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN mkdir -p $HADOOP_DATA/current/data/hdfs/namenode
RUN mkdir -p $HADOOP_DATA/current/data/hdfs/datanode

# Configure YARN
ADD config/yarn-site.xml /tmp/yarn-site.xml
ADD config/mapred-site.xml /tmp/mapred-site.xml
RUN rm $HADOOP_HOME/etc/hadoop/yarn-site.xml
RUN mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
RUN mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Copy start-hadoop script
ADD services/start-hadoop.sh /tmp/start-hadoop.sh
RUN mv /tmp/start-hadoop.sh $HADOOP/bin/start-hadoop.sh

# Configure directory ownership
RUN chown -R hduser:hduser /home/hduser
RUN chown -R hduser:hadoop $HADOOP_HOME/
RUN chown -R hduser:hadoop $HADOOP_DATA/
RUN chmod 1777 /tmp

# Format namenode
RUN su hduser -c "$HADOOP_HOME/bin/hdfs namenode -format"

# HDFS ports
EXPOSE 50070 50470 9000 50075 50475 50010 50020 50090

# YARN ports
EXPOSE 8088 8032 50060

CMD ["/bin/bash", "start-hadoop.sh"]

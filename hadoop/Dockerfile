# Install dependencies
FROM eclipse-temurin:17-jdk AS base

ENV HADOOP_VERSION=3.4.2
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONFIG_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt-get update && \
    apt-get install -y --no-install-recommends ssh pdsh


# Install hadoop
FROM base AS hadoop-installation

RUN wget -O /tmp/hadoop.tar.gz "https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION-lean.tar.gz" && \
    tar -xzf /tmp/hadoop.tar.gz -C /opt && \
    rm /tmp/hadoop.tar.gz


# Configure hadoop
FROM hadoop-installation AS hadoop-configuration

COPY hadoop/core-site.xml $HADOOP_CONFIG_DIR/core-site.xml
COPY hadoop/hdfs-site.xml $HADOOP_CONFIG_DIR/hdfs-site.xml


# Prepare runtime
FROM hadoop-configuration AS runtime

RUN ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys

COPY hadoop/start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]

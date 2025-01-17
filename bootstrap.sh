#!/usr/bin/env bash

LOG_FILE="/home/vagrant/bootstrap.sh.log"

sudo chown -R vagrant /home/vagrant
sudo chgrp -R vagrant /home/vagrant

# Setup a swap partition
sudo fallocate -l 8G /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1M count=8192
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

#
# Update & install dependencies
#
sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade
sudo apt-get install -y zip unzip curl bzip2 python-dev build-essential git libssl1.0.0 libssl-dev \
    software-properties-common debconf-utils apt-transport-https

#
# Uncomment below to install Oracle Java8 (No longer available from ppa)
#

# sudo add-apt-repository -y ppa:webupd8team/java
# sudo apt-get update
# echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
# sudo apt-get install -y oracle-java8-installer oracle-java8-set-default
# cd /var/lib/dpkg/info
# sudo sed -i 's|JAVA_VERSION=8u151|JAVA_VERSION=8u162|' oracle-java8-installer.*
# sudo sed -i 's|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/|' oracle-java8-installer.*
# sudo sed -i 's|SHA256SUM_TGZ="c78200ce409367b296ec39be4427f020e2c585470c4eed01021feada576f027f"|SHA256SUM_TGZ="68ec82d47fd9c2b8eb84225b6db398a72008285fafc98631b1ff8d2229680257"|' oracle-java8-installer.*
# sudo sed -i 's|J_DIR=jdk1.8.0_151|J_DIR=jdk1.8.0_162|' oracle-java8-installer.*
# echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
# sudo apt-get install -y oracle-java8-installer oracle-java8-set-default

sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee -a /home/vagrant/.bash_profile

#
# Install Miniconda
#
curl -Lko /tmp/Miniconda3-latest-Linux-x86_64.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x /tmp/Miniconda3-latest-Linux-x86_64.sh
/tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /home/vagrant/anaconda

export PATH=/home/vagrant/anaconda/bin:$PATH
echo 'export PATH=/home/vagrant/anaconda/bin:$PATH' | sudo tee -a /home/vagrant/.bash_profile

sudo chown -R vagrant /home/vagrant/anaconda
sudo chgrp -R vagrant /home/vagrant/anaconda

#
# Install Clone repo, install Python dependencies
#
cd /home/vagrant
git clone https://github.com/rjurney/Agile_Data_Code_2
cd /home/vagrant/Agile_Data_Code_2
export PROJECT_HOME=/home/vagrant/Agile_Data_Code_2
echo "export PROJECT_HOME=/home/vagrant/Agile_Data_Code_2" | sudo tee -a /home/vagrant/.bash_profile

conda install -y python=3.6.8
conda install -y iso8601 numpy scipy scikit-learn matplotlib ipython jupyter
pip install bs4 Flask beautifulsoup4 frozendict geopy kafka-python py4j pymongo pyelasticsearch requests selenium tabulate tldextract wikipedia findspark imongo-kernel

sudo chown -R vagrant /home/vagrant/Agile_Data_Code_2
sudo chgrp -R vagrant /home/vagrant/Agile_Data_Code_2
cd /home/vagrant

# Install commons-httpclient
curl -Lko /home/vagrant/Agile_Data_Code_2/lib/commons-httpclient-3.1.jar http://central.maven.org/maven2/commons-httpclient/commons-httpclient/3.1/commons-httpclient-3.1.jar

#
# Install Hadoop
#
curl -Lko /tmp/hadoop-3.0.1.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-3.0.1/hadoop-3.0.1.tar.gz
mkdir -p /home/vagrant/hadoop
cd /home/vagrant/
tar -xvf /tmp/hadoop-3.0.1.tar.gz -C hadoop --strip-components=1

echo "" >> /home/vagrant/.bash_profile
export HADOOP_HOME=/home/vagrant/hadoop
echo 'export HADOOP_HOME=/home/vagrant/hadoop' | sudo tee -a /home/vagrant/.bash_profile
export PATH=$PATH:$HADOOP_HOME/bin
echo 'export PATH=$PATH:$HADOOP_HOME/bin' | sudo tee -a /home/vagrant/.bash_profile
export HADOOP_CLASSPATH=$(hadoop classpath)
echo 'export HADOOP_CLASSPATH=$(hadoop classpath)' | sudo tee -a /home/vagrant/.bash_profile
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' | sudo tee -a /home/vagrant/.bash_profile

# Give to vagrant
echo $LOG_FILE
echo "Giving hadoop to user vagrant ..." | tee -a $LOG_FILE
sudo chown -R vagrant /home/vagrant/hadoop
sudo chgrp -R vagrant /home/vagrant/hadoop

#
# Install Spark
#
echo "" | tee -a $LOG_FILE
echo "Downloading and installing Spark 2.2.1 ..." | tee -a $LOG_FILE
curl -Lko /tmp/spark-2.2.1-bin-without-hadoop.tgz https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
mkdir -p /home/vagrant/spark
cd /home/vagrant
tar -xvf /tmp/spark-2.2.1-bin-without-hadoop.tgz -C spark --strip-components=1

echo "" >> /home/vagrant/.bash_profile
echo "# Spark environment setup" | sudo tee -a /home/vagrant/.bash_profile
export SPARK_HOME=/home/vagrant/spark
echo 'export SPARK_HOME=/home/vagrant/spark' | sudo tee -a /home/vagrant/.bash_profile
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/' | sudo tee -a /home/vagrant/.bash_profile
export SPARK_DIST_CLASSPATH=`$HADOOP_HOME/bin/hadoop classpath`
echo 'export SPARK_DIST_CLASSPATH=`$HADOOP_HOME/bin/hadoop classpath`' | sudo tee -a /home/vagrant/.bash_profile
export PATH=$PATH:$SPARK_HOME/bin
echo 'export PATH=$PATH:$SPARK_HOME/bin' | sudo tee -a /home/vagrant/.bash_profile

# Have to set spark.io.compression.codec in Spark local mode
cp /home/vagrant/spark/conf/spark-defaults.conf.template /home/vagrant/spark/conf/spark-defaults.conf
echo 'spark.io.compression.codec org.apache.spark.io.SnappyCompressionCodec' | sudo tee -a /home/vagrant/spark/conf/spark-defaults.conf

# Give Spark 8GB of RAM, use Python3
echo "spark.driver.memory 8g" | sudo tee -a $SPARK_HOME/conf/spark-defaults.conf
echo "spark.executor.cores 2" | sudo tee -a $SPARK_HOME/conf/spark-defaults.conf
echo "PYSPARK_PYTHON=python3" | sudo tee -a $SPARK_HOME/conf/spark-env.sh
echo "PYSPARK_DRIVER_PYTHON=python3" | sudo tee -a $SPARK_HOME/conf/spark-env.sh

# Setup log4j config to reduce logging output
cp $SPARK_HOME/conf/log4j.properties.template $SPARK_HOME/conf/log4j.properties
sed -i 's/INFO/ERROR/g' $SPARK_HOME/conf/log4j.properties

# Give to vagrant
sudo chown -R vagrant /home/vagrant/spark
sudo chgrp -R vagrant /home/vagrant/spark

#
# Install MongoDB and dependencies
#
sudo apt-get install -y mongodb
sudo mkdir -p /data/db
sudo chown -R mongodb /data/db
sudo chgrp -R mongodb /data/db

# run MongoDB as daemon
sudo systemctl start mongodb

# Get the MongoDB Java Driver
echo "curl -sLko /home/vagrant/Agile_Data_Code_2/lib/mongo-java-driver-3.6.1.jar https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongo-java-driver/3.6.1/mongo-java-driver-3.6.1.jar"
curl -sLko /home/vagrant/Agile_Data_Code_2/lib/mongo-java-driver-3.6.1.jar https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongo-java-driver/3.6.1/mongo-java-driver-3.6.1.jar

# Install the mongo-hadoop project in the mongo-hadoop directory in the root of our project.
curl -Lko /tmp/mongo-hadoop-r2.0.2.tar.gz https://github.com/mongodb/mongo-hadoop/archive/r2.0.2.tar.gz
mkdir /home/vagrant/mongo-hadoop
cd /home/vagrant
tar -xvzf /tmp/mongo-hadoop-r2.0.2.tar.gz -C mongo-hadoop --strip-components=1
rm -rf /tmp/mongo-hadoop-r2.0.2.tar.gz

# Now build the mongo-hadoop-spark jars
cd /home/vagrant/mongo-hadoop
./gradlew jar
cp /home/vagrant/mongo-hadoop/spark/build/libs/mongo-hadoop-spark-*.jar /home/vagrant/Agile_Data_Code_2/lib/
cp /home/vagrant/mongo-hadoop/build/libs/mongo-hadoop-*.jar /home/vagrant/Agile_Data_Code_2/lib/
cd /home/vagrant

# Now build the pymongo_spark package
cd /home/vagrant/mongo-hadoop/spark/src/main/python
python setup.py install
cp /home/vagrant/mongo-hadoop/spark/src/main/python/pymongo_spark.py /home/vagrant/Agile_Data_Code_2/lib/
export PYTHONPATH=$PYTHONPATH:$PROJECT_HOME/lib
echo "" | sudo tee -a /home/vagrant/.bash_profile
echo 'export PYTHONPATH=$PYTHONPATH:$PROJECT_HOME/lib' | sudo tee -a /home/vagrant/.bash_profile
cd /home/vagrant

rm -rf /home/vagrant/mongo-hadoop

#
# Install ElasticSearch in the elasticsearch directory in the root of our project, and the Elasticsearch for Hadoop package
#
echo "curl -sLko /tmp/elasticsearch-5.6.0.tar.gz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.0.tar.gz"
curl -sLko /tmp/elasticsearch-5.6.0.tar.gz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.0.tar.gz
mkdir /home/vagrant/elasticsearch
cd /home/vagrant
tar -xvzf /tmp/elasticsearch-5.6.0.tar.gz -C elasticsearch --strip-components=1
sudo chown -R vagrant /home/vagrant/elasticsearch
sudo chgrp -R vagrant /home/vagrant/elasticsearch
sudo mkdir -p /home/vagrant/elasticsearch/logs
sudo chown -R vagrant /home/vagrant/elasticsearch/logs
sudo chgrp -R vagrant /home/vagrant/elasticsearch/logs

# Run elasticsearch
sudo -u vagrant /home/vagrant/elasticsearch/bin/elasticsearch -d # re-run if you shutdown your computer

# Run a query to test - it will error but should return json
echo "Testing Elasticsearch with a query ..." | tee -a $LOG_FILE
curl 'localhost:9200/agile_data_science/on_time_performance/_search?q=Origin:ATL&pretty'

# Install Elasticsearch for Hadoop
echo "curl -sLko /tmp/elasticsearch-hadoop-6.1.2.zip http://download.elastic.co/hadoop/elasticsearch-hadoop-6.1.2.zip"
curl -sLko /tmp/elasticsearch-hadoop-6.1.2.zip http://download.elastic.co/hadoop/elasticsearch-hadoop-6.1.2.zip
unzip /tmp/elasticsearch-hadoop-6.1.2.zip
mv /home/vagrant/elasticsearch-hadoop-6.1.2 /home/vagrant/elasticsearch-hadoop
cp /home/vagrant/elasticsearch-hadoop/dist/elasticsearch-hadoop-6.1.2.jar /home/vagrant/Agile_Data_Code_2/lib/
cp /home/vagrant/elasticsearch-hadoop/dist/elasticsearch-spark-20_2.11-6.1.2.jar /home/vagrant/Agile_Data_Code_2/lib/
echo "spark.speculation false" | sudo tee -a /home/vagrant/spark/conf/spark-defaults.conf
rm -f /tmp/elasticsearch-hadoop-6.1.2.zip
rm -rf /home/vagrant/elasticsearch-hadoop/conf/spark-defaults.conf

#
# Spark jar setup
#

# Install and add snappy-java and lzo-java to our classpath below via spark.jars
echo "" | tee -a $LOG_FILE
echo "Installing snappy-java and lzo-java and adding them to our classpath ..." | tee -a $LOG_FILE
cd /home/vagrant/Agile_Data_Code_2
curl -sLko lib/snappy-java-1.1.7.1.jar http://central.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.7.1/snappy-java-1.1.7.1.jar
curl -sLko lib/lzo-hadoop-1.0.5.jar http://central.maven.org/maven2/org/anarres/lzo/lzo-hadoop/1.0.5/lzo-hadoop-1.0.5.jar
cd /home/vagrant

# Set the spark.jars path
echo "spark.jars /home/vagrant/Agile_Data_Code_2/lib/mongo-hadoop-spark-2.0.2.jar,/home/vagrant/Agile_Data_Code_2/lib/mongo-java-driver-3.6.1.jar,/home/vagrant/Agile_Data_Code_2/lib/mongo-hadoop-2.0.2.jar,/home/vagrant/Agile_Data_Code_2/lib/elasticsearch-spark-20_2.11-6.1.2.jar,/home/vagrant/Agile_Data_Code_2/lib/snappy-java-1.1.7.1.jar,/home/vagrant/Agile_Data_Code_2/lib/lzo-hadoop-1.0.5.jar,/home/vagrant/Agile_Data_Code_2/lib/commons-httpclient-3.1.jar" | sudo tee -a /home/vagrant/spark/conf/spark-defaults.conf

#
# Kafka install and setup
#
echo "" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "Downloading and installing Kafka version 2.1.1 for Scala 2.11 ..." | tee -a $LOG_FILE
curl -Lko /tmp/kafka_2.11-2.1.1.tgz https://www-us.apache.org/dist/kafka/2.1.1/kafka_2.11-2.1.1.tgz
mkdir -p /home/vagrant/kafka
cd /home/vagrant/
tar -xvzf /tmp/kafka_2.11-2.1.1.tgz -C kafka --strip-components=1 && rm -f /tmp/kafka_2.11-2.1.1.tgz

# Set the log dir to kafka/logs
sed -i '/log.dirs=\/tmp\/kafka-logs/c\log.dirs=logs' /home/vagrant/kafka/config/server.properties

# Give to vagrant
echo "Giving Kafka to user vagrant ..." | tee -a $LOG_FILE
sudo chown -R vagrant /home/vagrant/kafka
sudo chgrp -R vagrant /home/vagrant/kafka

# Set the log dir to kafka/logs
echo "Configuring logging for kafka to go into kafka/logs directory ..." | tee -a $LOG_FILE
sed -i '/log.dirs=\/tmp\/kafka-logs/c\log.dirs=logs' /home/vagrant/kafka/config/server.properties

# Run zookeeper (which kafka depends on), then Kafka
echo "Running Zookeeper as a daemon ..." | tee -a $LOG_FILE
sudo -H -u vagrant /home/vagrant/kafka/bin/zookeeper-server-start.sh -daemon /home/vagrant/kafka/config/zookeeper.properties
echo "Running Kafka Server as a daemon ..." | tee -a $LOG_FILE
sudo -H -u vagrant /home/vagrant/kafka/bin/kafka-server-start.sh -daemon /home/vagrant/kafka/config/server.properties

#
# Install and setup Airflow
#
echo "export SLUGIFY_USES_TEXT_UNIDECODE=yes"
export SLUGIFY_USES_TEXT_UNIDECODE=yes
pip install apache-airflow[hive]
mkdir /home/vagrant/airflow
mkdir /home/vagrant/airflow/dags
mkdir /home/vagrant/airflow/logs
mkdir /home/vagrant/airflow/plugins

sudo chown -R vagrant /home/vagrant/airflow
sudo chgrp -R vagrant /home/vagrant/airflow

airflow initdb
airflow webserver -D &
airflow scheduler -D &

# Install Apache Zeppelin
echo "curl -sLko /tmp/zeppelin-0.7.3-bin-all.tgz https://archive.apache.org/dist/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-all.tgz"
curl -sLko /tmp/zeppelin-0.7.3-bin-all.tgz https://archive.apache.org/dist/zeppelin/zeppelin-0.7.3/zeppelin-0.7.3-bin-all.tgz
mkdir zeppelin
tar -xvzf /tmp/zeppelin-0.7.3-bin-all.tgz -C zeppelin --strip-components=1

# Configure Zeppelin
cp zeppelin/conf/zeppelin-env.sh.template zeppelin/conf/zeppelin-env.sh
echo "export SPARK_HOME=$PROJECT_HOME/spark" >> zeppelin/conf/zeppelin-env.sh
echo "export SPARK_MASTER=local" >> zeppelin/conf/zeppelin-env.sh
echo "export SPARK_CLASSPATH=" >> zeppelin/conf/zeppelin-env.sh

# Jupyter server setup
jupyter notebook --generate-config
mkdir /root/.jupyter/
cp /home/vagrant/Agile_Data_Code_2/jupyter_notebook_config.py /root/.jupyter/
mkdir /root/certs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -subj "/C=US" -keyout /root/certs/mycert.pem -out /root/certs/mycert.pem

cd /home/vagrant/Agile_Data_Code_2
jupyter notebook --ip=0.0.0.0 --NotebookApp.token= --allow-root --no-browser &
cd

# =======
sudo chown -R vagrant /home/vagrant/airflow
sudo chgrp -R vagrant /home/vagrant/airflow

echo "sudo chown -R vagrant /home/vagrant/airflow" | sudo tee -a /home/vagrant/.bash_profile
echo "sudo chgrp -R vagrant /home/vagrant/airflow" | sudo tee -a /home/vagrant/.bash_profile

# Install Ant to build Cassandra
sudo apt-get install -y ant

# Install Cassandra - must build from source as the latest 3.11.1 build is broken...
git clone https://github.com/apache/cassandra
cd cassandra
git checkout cassandra-3.11
ant
bin/cassandra
export PATH=$PATH:/home/vagrant/cassandra/bin
echo 'export PATH=$PATH:/home/vagrant/cassandra/bin' | sudo tee -a /home/vagrant/.bash_profile
cd ..

# Install and setup JanusGraph
cd /home/vagrant
curl -Lko /tmp/janusgraph-0.2.0-hadoop2.zip \
  https://github.com/JanusGraph/janusgraph/releases/download/v0.2.0/janusgraph-0.2.0-hadoop2.zip
unzip -d . /tmp/janusgraph-0.2.0-hadoop2.zip
mv janusgraph-0.2.0-hadoop2 janusgraph
rm /tmp/janusgraph-0.2.0-hadoop2.zip

# Download data
cd /home/vagrant/Agile_Data_Code_2
./download.sh

# Install phantomjs
/home/vagrant/Agile_Data_Code/install/phantomjs.sh

# make sure we own /home/vagrant/.bash_profile after all the 'sudo tee'
sudo chgrp vagrant /home/vagrant/.bash_profile
sudo chown vagrant /home/vagrant/.bash_profile

#
# Cleanup
#
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "DONE!"

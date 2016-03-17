FROM ubuntu:14.04
MAINTAINER wingerath wolfram@wingerath.org

# The following files have to be provided by the operator:
# /usr/share/storm/conf/storm.yaml
# /usr/share/storm/logback/cluster.xml




# The used storm version:
ENV STORM_VERSION apache-storm-0.9.5

# derived parameters
ENV STORM_HOME /usr/share/${STORM_VERSION}
ENV STORM_LOCAL ${STORM_HOME}/storm-local

WORKDIR ${STORM_HOME}

# supervisor: worker ports
EXPOSE 6700
EXPOSE 6701
EXPOSE 6702
EXPOSE 6703
# logviewer
EXPOSE 8000
# DRPC
EXPOSE 6627
EXPOSE 3772
EXPOSE 3773


# setting up config files
RUN export JAVA_HOME=/usr/lib/jvm/java-8-oracle


# Install stuff
RUN \
   apt-get update -y && apt-get install -y \
   unzip \
   make \
   build-essential \
   uuid-dev \
   libtool \
   python python-dev python-distribute python-pip \
   pkg-config \
   autoconf

RUN alias python=python3

# Install Java 8
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y  software-properties-common && \
  add-apt-repository ppa:webupd8team/java -y && \
  apt-get update && \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
  apt-get install -y oracle-java8-installer && \
  apt-get clean

# download storm
RUN wget -q -N http://mirrors.gigenet.com/apache/storm/${STORM_VERSION}/${STORM_VERSION}.zip
RUN unzip -o ${STORM_VERSION}.zip -d /usr/share/
RUN rm ${STORM_VERSION}.zip

RUN groupadd storm
RUN useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm
RUN chown -R storm:storm ${STORM_HOME}
RUN mkdir /var/log/storm
RUN chown -R storm:storm /var/log/storm

# add startup script
ADD start-supervisor.sh ${STORM_HOME}/start-supervisor.sh



# make the storm directory available via /usr/share/storm
RUN ln -s /usr/share/${STORM_VERSION} /usr/share/storm

# remove files that should be provided by the user
RUN rm conf/storm.yaml logback/cluster.xml

ENTRYPOINT ["/usr/share/storm/start-supervisor.sh"]
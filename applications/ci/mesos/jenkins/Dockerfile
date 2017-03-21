FROM jenkins:2.32.3

USER root

RUN apt-get update && \
    apt-get -y install lsb-release

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF && \
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') && \
    CODENAME=$(lsb_release -cs) && \
    echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update

ENV MESOS_VERSION 1.1.0

RUN apt-get -y install mesos=${MESOS_VERSION}*

ENV LIBPROCESS_PORT 45000

ENV JAVA_OPTS "$JAVA_OPT -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-scripts; default-src 'none'; script-src 'self' 'unsafe-inline'; img-src 'self'; style-src 'self' 'unsafe-inline';\""

EXPOSE 45000

COPY bootstrap.sh /usr/local/bin/bootstrap.sh

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

RUN /usr/local/bin/install-plugins.sh mesos:0.14.1

ENTRYPOINT ["bootstrap.sh"]

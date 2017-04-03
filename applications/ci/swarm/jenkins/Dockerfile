FROM jenkins:2.32.3

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

RUN /usr/local/bin/install-plugins.sh swarm:3.3 blueocean:1.0.0-rc3

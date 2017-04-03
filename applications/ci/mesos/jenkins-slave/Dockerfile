FROM maven:3

RUN apt-get update && \
    apt-get -y install apt-transport-https software-properties-common

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian \
    				   $(lsb_release -cs) \
    				   stable"

RUN apt-get update && \
    apt-get -y install docker-ce
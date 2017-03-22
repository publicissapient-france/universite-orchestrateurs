FROM maven:3

RUN apt-get update && \
    apt-get install -y apt-transport-https software-properties-common && \
    apt-get clean

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian \
    				   $(lsb_release -cs) \
    				   stable"

RUN apt-get update && \
    apt-get install -y docker-ce && \
    apt-get clean
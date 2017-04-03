FROM jenkinsci/jnlp-slave:2.62

USER root

RUN apt-get update -y && \
    apt-get install -y jq git &&  \
    curl -sSL https://get.docker.com/ | sh && \
    apt-get clean

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl
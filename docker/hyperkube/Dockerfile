FROM quay.io/coreos/hyperkube:v1.5.4_coreos.0

RUN apt-get update && apt-get install -y curl && \
    curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable && \
    rexray flexrex install && \
    apt-get clean


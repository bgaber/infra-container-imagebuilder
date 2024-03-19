# Pull Base Image
FROM alpine:3.14

# Set Labels
LABEL maintainer "DL-CC-CTS-CloudOps <DL-CC-CTS-CloudOps@compucom.com>"

# Set Vars
ENV PACKER_VERSION=1.8.5

# Install Everything
RUN apk --no-cache add \
        sudo \
        python3 \
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        bash \
        wget \
        nano \
        git \
        cargo \
        gcc && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        musl-dev \
        build-base && \
    pip3 install --upgrade pip cffi && \
    pip3 install wheel && \
    pip3 install ansible && \
    pip3 install ansible-lint==6.2.2 && \
    pip3 install --upgrade pywinrm && \
    pip3 install boto3 && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

# Setup
RUN mkdir /buildzone && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts && \
    echo '[defaults]' > /etc/ansible/ansible.cfg && \
    echo '# timeout= this is the default timeout for connection plugins to use' >> /etc/ansible/ansible.cfg && \
    echo '# default value is 10 seconds' >> /etc/ansible/ansible.cfg && \
    echo 'timeout=30' >> /etc/ansible/ansible.cfg && \
    addgroup -S builder && \
    adduser -S builder -G builder && \
    chown builder /buildzone && \
    echo 'builder    ALL=(ALL) ALL' && \
    wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip && \
    wget -q https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.10.1/packer-provisioner-windows-update_0.10.1_linux_amd64.tar.gz && \
    tar -zxvf packer-provisioner-windows-update_0.10.1_linux_amd64.tar.gz && \
    mv packer-provisioner-windows-update /bin && \
    rm -rf packer-provisioner-windows-update_0.10.1_linux_amd64.tar.gz

WORKDIR /buildzone
USER builder

ENTRYPOINT ["/bin/packer"]
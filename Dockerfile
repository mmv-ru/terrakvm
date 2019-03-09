FROM golang:alpine

ENV PACKAGES="wget unzip git pkgconfig libvirt-dev gcc musl-dev nano cdrkit xz qemu-img openssh"
ENV TERRAFORM_VER=0.11.11 \
    DUMB_INIT_VER=1.2.1 \
    LIBVIRT_GO_VER=v5.1.0 \
    TERRAFORM_PROVIDER_LIBVIRT_VER=v0.5.1

RUN apk add --no-cache $PACKAGES 2>/dev/null || \
    yum install -y $PACKAGES 2>/dev/null || \
    (apt update && apt install -y $PACKAGES) 2>/dev/null || \
    pacman -Syu $PACKAGES --noconfirm 2>/dev/null

RUN wget -qO /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64 \
    && chmod +x /usr/local/bin/dumb-init

RUN wget -qO /tmp/tf.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip \
    && unzip /tmp/tf.zip -d /usr/bin \
    && rm -f /tmp/tf.zip \
    && chmod 755 /usr/bin/terraform

RUN go get github.com/libvirt/libvirt-go \
    && go get github.com/dmacvicar/terraform-provider-libvirt

RUN cd $GOPATH/src/github.com/libvirt/libvirt-go \
    && git checkout -b ${LIBVIRT_GO_VER} \
    && go get

RUN cd $GOPATH/src/github.com/dmacvicar/terraform-provider-libvirt \
    && git checkout -b ${TERRAFORM_PROVIDER_LIBVIRT_VER} \
    && go get

RUN cd $GOPATH/src/github.com/dmacvicar/terraform-provider-libvirt  \
    && go install \
    && mkdir -p /root/.terraform.d/plugins \
    && mv $GOPATH/bin/terraform-provider-libvirt /root/.terraform.d/plugins \
    && mkdir -p /root/.cache/libvirt/ \
    && mkdir -p /var/run/libvirt

WORKDIR /terraform

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["dumb-init", "--", "/entrypoint.sh"]
CMD []

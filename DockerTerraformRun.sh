#!/bin/sh

sudo docker run --privileged -it --rm \
      -v /var/run/libvirt/libvirt-sock:/libvirt-sock \
      -v $PWD:/terraform \
      --volume $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent \
      mmv/terrakvm \
      terraform $@

#!/bin/sh

ROORMARKER=projectroot
CURRENT="$PWD"
while [[ $PWD != / ]] ; do
    test -e "$ROORMARKER" && break
    cd ..
done
ROOT="$PWD"
RELPATH=$(realpath --relative-to="$ROOT" "$CURRENT")
echo context: $ROOT
echo relpath: $RELPATH

sudo docker run --privileged -it --rm \
      -v /var/run/libvirt/libvirt-sock:/libvirt-sock \
      -v $ROOT:/terraform \
      -w /terraform/$RELPATH \
      -v $SSH_AUTH_SOCK:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent \
      mmv/terrakvm \
      terraform $@

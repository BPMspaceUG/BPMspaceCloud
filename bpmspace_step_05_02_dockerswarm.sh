#!/bin/bash
sudo mkdir /etc/systemd/system/docker.service.d -p
sudo cp /mnt/gluster/gluster_bpmspacecloud/BPMspaceCloud/dockerhost/docker-api/startup_options.conf /etc/systemd/system/docker.service.d/
sudo systemctl daemon-reload && sudo systemctl restart docker.service
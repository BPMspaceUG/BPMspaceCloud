# BPMspaceCloud

## DockerHosts Initial Setup

### for setup the 1st Master 
> * wget https://raw.githubusercontent.com/BPMspaceUG/BPMspaceCloud/master/bpmspace_setup_dockerhost_stretch.sh
> * chmod +x bpmspace_setup_dockerhost_stretch.sh
> * ./bpmspace_setup_dockerhost_stretch.sh MASTER docker_master_001.bpmspace.net

### for setup the 1st NODE (WORKER) 
> * wget https://raw.githubusercontent.com/BPMspaceUG/BPMspaceCloud/master/bpmspace_setup_dockerhost_stretch.sh
> * chmod +x bpmspace_setup_dockerhost_stretch.sh
> * ./bpmspace_setup_dockerhost_stretch.sh WORKER docker_node_001.bpmspace.net

### for setup the 2nd NODE (WORKER) 
> * wget https://raw.githubusercontent.com/BPMspaceUG/BPMspaceCloud/master/bpmspace_setup_dockerhost_stretch.sh
> * chmod +x bpmspace_setup_dockerhost_stretch.sh
> * ./bpmspace_setup_dockerhost_stretch.sh WORKER docker_node_002.bpmspace.net

## DockerSwarm Initial Setup

BPMspaceCloud DockerSwarm is based on the Imixs-Cloud - https://github.com/imixs/imixs-cloud

_Imixs-Cloud_ is an open infrastructure project, providing a lightweight [docker](https://www.docker.com/) based container environment for production business applications. The main objectives of this project are **simplicity**, **transparency** and **operational readiness**. 
The _Imixs-Cloud_ is based on a [docker swarm](https://docs.docker.com/engine/swarm/) cluster environment.
Docker swarm is much easier to setup and in its management compared to a Kubernetes cluster. However, when deciding which platform  to use, you should consider your own criterias. _Imixs-Cloud_ is optimized to **build**, **run** and **maintain** business services in small and medium-sized enterprises.

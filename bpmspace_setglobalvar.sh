#!/bin/bash
# Check if $DOCKER_SWARM_TYPE, $DOCKER_SWARM_ENV and $DOCKER_SWARM_SUBENV exists else exit with error messages "othe follwoing global varaible |name of the varibale] is not set
echo "DOCKER_SWARM_TYPE: " $DOCKER_SWARM_TYPE;
echo "DOCKER_SWARM_ENV: " $DOCKER_SWARM_ENV;
echo "DOCKER_SWARM_SUBENV: " $DOCKER_SWARM_SUBENV;
# Check if $DOCKER_SWARM_TYPE = MASTER or NODE - else exit with error message "DOCKER_SWARM_TYPE must have the value MASTER or NODE"
# Check if $DOCKER_SWARM_ENV = PRODSTAGE or DEVTEST - else exit with error message "$DOCKER_SWARM_ENV must have the value PRODSTAGE or DEVTEST"
# Check if $DOCKER_SWARM_SUBENV is in $DOCKER_SWARM_ENV included - 
#		IF $DOCKER_SWARM_ENV is "PRODSTAGE" $DOCKER_SWARM_SUBENV can only be PROD OR STAGE else "error messages The DOCKER_SWARM_ENV is set to $DOCKER_SWARM_ENV so $DOCKER_SWARM_SUBENV must be PROD or STAGE"
#		IF $DOCKER_SWARM_ENV is "DEVTEST" $DOCKER_SWARM_SUBENV can only be DEV OR TEST else "error messages The DOCKER_SWARM_ENV is set to $DOCKER_SWARM_ENV so $DOCKER_SWARM_SUBENV must be DEV or TEST"
	
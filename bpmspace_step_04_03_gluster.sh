#!/bin/bash
gluster peer probe $MASTER001IP
gluster peer probe $NODE002IP
gluster pool list
gluster volume create gluster_bpmspacecloud \
		replica 3 \
		$MASTER001IP:/gluster/bricks/$MASTER001NAME/brick \
		$NODE001IP:/gluster/bricks/$NODE001NAME/brick \
		$NODE002IP:/gluster/bricks/$NODE002NAME/brick
gluster volume start gluster_bpmspacecloud
gluster volume set gluster_bpmspacecloud auth.allow $MASTER001IP,$NODE001IP,$NODE002IP
gluster volume create gluster_bpmspacecloud_nodes \
		replica 2 \
		$NODE001IP:/gluster/bricks/$NODE001NAME/brick2 \
		$NODE002IP:/gluster/bricks/$NODE002NAME/brick2
gluster volume start gluster_bpmspacecloud_nodes
gluster volume set gluster_bpmspacecloud auth.allow $NODE001NAME,$NODE002NAME
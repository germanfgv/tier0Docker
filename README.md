### WMAgent in Docker within a T0 machine.

Requires Docker to be installed an agent VM (vocmsXXXX) running a schedd.

Default build options are defined in `install.sh`. Builds a Docker image via standard deployment scripts. The image only contains things common to all agents. 
```
WMA_TAG=1.3.3.patch3
DEPLOY_TAG=HG2006e
WMA_ARCH=slc7_amd64_gcc630
REPO="comp=comp"
```

Run options are defined in `run.sh`. A JobSubmitter patch from PR 9453 is required if you want to run workflows. Configures things unique to an agent running in a container, initializes the agent config and databases
```
WMA_TAG=1.3.3.patch3
DEPLOY_TAG=HG2006e
TEAMNAME=Tier0Replay
CENTRAL_SERVICES=cmsweb-testbed.cern.ch
AG_NUM=0
FLAVOR=mysql
PATCHES=""
```
`WMA_TAG` and `DEPLOY_TAG` must match what is in install.sh. You should use WMAgent 1.3.3.patch3 or later. This in order to avoid needing obsolete dashboard services.

Patch 9453 includes changes to SimpleCondorPlugin.py and WMAgentConfig.py that allow the agent to properly run inside docker. They are also changes to unittest.

Building the image

```
docker build --network=host .
```

Running a WMAgent container

For now when you start a container it simply drops you to a login shell, allowing you to run `run.sh` manually. You must bind mount several directories and update the selinux lables with the Z option (on vocmsXXXX hosts).
* /data/certs
* /etc/condor (schedd runs on the host, not the container)
* /tmp
* /data/srv/wmagent/current/install (stateful service and component dirs)
* /data/srv/wmagent/current/config

The config folder must contain ./wmagent/config.py file. This file in not usually present in Tier0 machines, so it must be created beforehand. Take in mind that components paths must match those inside the container. Also, you must provide a ReqMgrURL2, usually ignored in tier0 config files. 

Right now, there is an issue with the wmagent-mod-config that prevents it to automatically generate workspace/config.py, so you may need to manually copy or soft-link wmagent/config.py

You also need to bind mount the secrets file.
* /data/admin/wmagent/WMAgent.secrets

This container uses MySQL instead of Oracle DB, so you need to add MySQL credentials and remove Oracle credentials. 

The install and config dirs will be initialized the first time you execute run.sh and a .dockerinit file will be placed to keep track of the initialization. Subsequent container restarts won't touch these directories.

Run command:
```
docker run --network=host --rm -h `hostname -f` -it \
-v /data/certs:/data/certs:Z \
-v /etc/condor:/etc/condor:Z \
-v /tmp:/tmp:Z \
-v /data/tier0/srv/wmagent/current/install:/data/srv/wmagent/current/install:Z \
-v /data/tier0/srv/wmagent/current/config:/data/srv/wmagent/current/config:Z \
-v /data/tier0/admin/Docker.secrets:/data/admin/wmagent/WMAgent.secrets:Z \
<image>
```

You can also use the `runT0Docker.sh` script included in this repository.

### Running the Agent

I've found that it is neccessary to run a `$manage clean-agent` before in order to create MySQL tables. This should be corrected in the future but, for now, it is the first command you should execute. Then, the `run.sh` script will initialize MariaDB and CouchDB. Source the agent environment and `$manage start-agent` and your Docker agent should be up and running.


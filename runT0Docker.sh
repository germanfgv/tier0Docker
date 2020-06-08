IMAGE=wmagent_condor:1.2.8

if [[ $# -ne 0 ]]; then
    IMAGE=$1; echo image$IMAGE
fi

docker run --network=host --rm -h  `hostname -f` -u cmst1 -it \
-v /data/certs:/data/certs:Z \
-v /etc/condor:/etc/condor:Z \
-v /tmp:/tmp:Z \
-v /data/tier0/srv/wmagent/current/install:/data/srv/wmagent/current/install:Z \
-v /data/tier0/srv/wmagent/current/config:/data/srv/wmagent/current/config:Z \
-v /data/tier0/admin/wmagent/Docker.secrets:/data/admin/wmagent/WMAgent.secrets:Z \
-d $IMAGE /bin/bash -c "/data/run.sh;source /data/admin/wmagent/env.sh;$manage start-agent;/bin/bash"

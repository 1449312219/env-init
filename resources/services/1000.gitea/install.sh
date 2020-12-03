name=gitea
chart=${name}-0.2.1.tgz

registry=${MASTER_IP}:${DOCKER_REGISTRY_PORT}
giteaPvcName=${name}-gitea
postgresPvcName=${name}-postgres
secretName=${name}-externaldb

if test ${registry} != : ;then
  set=images.gitea=${registry}/gitea/gitea:1.12.2
  set=${set},images.postgres=${registry}/postgres:11
  set=${set},images.memcached=${registry}/memcached:1.5.19-alpine
  set=${set},service.http.externalHost=${MASTER_IP}
  set=${set},service.ssh.externalHost=${MASTER_IP}
fi
#set=$set,persistence.giteaSize=8Gi,persistence.accessMode=ReadWriteOnce

helm upgrade --install ${name} ${chart} -f values.yaml --set=${set}


# 创建PV
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${giteaPvcName}
spec:
  accessModes:
  - ReadWriteOnce
  - ReadWriteMany
  capacity:
    storage: 8Gi
  hostPath:
    path: /home/vagrant/pv/${giteaPvcName}
    type: DirectoryOrCreate
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${postgresPvcName}
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 5Gi
  hostPath:
    path: /home/vagrant/pv/${postgresPvcName}
    type: DirectoryOrCreate
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
EOF

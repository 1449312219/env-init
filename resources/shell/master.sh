set -ex
set -o pipefail

. ./init-env.sh

rm -rf ${JOIN_CMD_FILE}


#配置yum源
cp ${RESOURCES_ROOT}/repos/* /etc/yum.repos.d/
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo-back
sed -i '/enabled=1/ s/1/0/' /etc/yum.repos.d/local.repo

#修改yum配置
sed -i -e "/^cachedir/{s|.*|cachedir=${PACKAGES_ROOT}/yum|}" \
       -e "/^keepcache/s/=.*/=1/" /etc/yum.conf

#yum makecache fast -y


#初始化k8s环境
./init-k8s-context.sh


#运行docker regisgtry
registryName=docker-registry
registryLocalPath=${PACKAGES_ROOT}/docker/registry
docker load -i ${PACKAGES_ROOT}/docker/registry.tar
docker run --name=${registryName} -d --rm \
  -p${DOCKER_REGISTRY_PORT}:5000 \
  -v${registryLocalPath}:/var/lib/registry registry:2 


#运行k8s
LOG=/tmp/kubeadm-init.log
kubeadm init --kubernetes-version=v1.18.0 \
--image-repository=${DOCKER_REGISTRY_HOST}:${DOCKER_REGISTRY_PORT}/k8s.gcr.io \
--pod-network-cidr=${POD_CIDR} \
--apiserver-advertise-address=${IP} | tee ${LOG}

#bash -c "$(sed -n '/kubeadm join/,$ p' ~/abcd | tr '\n\' ' ')"
sed -n '/kubeadm join/,$ p' ${LOG}  > ${JOIN_CMD_FILE}

#单机
#kubeadm init --kubernetes-version=v1.18.0 --image-repository=localhost:5000/k8s.gcr.io --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.28.128.4  --node-name=172.28.128.4
#集群
#kubeadm init --kubernetes-version=v1.18.0 --image-repository=localhost:5000/k8s.gcr.io --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.28.128.4  --node-name=172.28.128.4 --control-plane-endpoint "k8s-2:6444" --upload-certs | tee ~/abcd

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


#在k8s运行docker regisgtry
docker stop ${registryName}
sed -e "s|\${NAME}|${registryName}|" \
    -e "s|\${LOCAL_REGISTRY_PATH}|${registryLocalPath}|" \
    -e "s|\${HOST_PORT}|${DOCKER_REGISTRY_PORT}|" \
  ${RESOURCES_ROOT}/k8s/${registryName}.yaml > /etc/kubernetes/manifests/${registryName}.yaml
until kubectl get pod docker-registry-$(hostname) ;do  sleep 3; done
#暴露为服务
kubectl expose pod ${registryName}-$(hostname) --name=${DOCKER_REGISTRY_HOST}


#运行calico
sed -r "/image/s|image: (.*)|image: ${DOCKER_REGISTRY_HOST}:${DOCKER_REGISTRY_PORT}/\1|" \
  ${RESOURCES_ROOT}/k8s/calico.yaml | kubectl apply -f -


#运行nginx, 暴露yum源
yum install -yC --nogpgcheck createrepo
createrepo ${PACKAGES_ROOT}/yum
sed -e "s|\${NAME}|nginx|" \
    -e "s|\${LOCAL_PACKAGES_PATH}|${PACKAGES_ROOT}/yum|" \
    -e "s|\${HOST_PORT}|${NGINX_PORT}|" \
    -e "s|\${REGISTRY_URL}|${DOCKER_REGISTRY_HOST}:${DOCKER_REGISTRY_PORT}|" \
  ${RESOURCES_ROOT}/k8s/nginx.yaml > /etc/kubernetes/manifests/nginx.yaml


#安装服务
./init-services.sh

#运行tekton
#./tekton/auto.sh

#运行helm
#./helm/auto.sh

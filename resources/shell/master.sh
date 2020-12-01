. ./init-env.sh

rm -rf $JOIN_CMD_FILE


#配置yum源
cp $ROOT/repos/* /etc/yum.repos.d/
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo-back
sed -i '/enabled=1/ s/1/0/' /etc/yum.repos.d/local.repo

#修改yum配置
sed -i '/^cachedir/{s|.*|cachedir=/home/vagrant/share/yum|};/^keepcache/s/=.*/=1/' /etc/yum.conf

yum makecache fast -y


./init-k8s-context.sh


#运行docker regisgtry
docker load -i $ROOT/docker/registry.tar
docker run --name=docker-registry -d --rm -p$DOCKER_REGISTRY_PORT:5000 -v/home/vagrant/share/docker/registry:/var/lib/registry registry:2 


#运行k8s
LOG=/tmp/kubeadm-init.log
kubeadm init --kubernetes-version=v1.18.0 --image-repository=$IP:$DOCKER_REGISTRY_PORT/k8s.gcr.io --pod-network-cidr=$POD_CIDR --apiserver-advertise-address=$IP | tee $LOG

#bash -c "$(sed -n '/kubeadm join/,$ p' ~/abcd | tr '\n\' ' ')"
sed -n '/kubeadm join/,$ p' $LOG  > $JOIN_CMD_FILE


#单机
#kubeadm init --kubernetes-version=v1.18.0 --image-repository=localhost:5000/k8s.gcr.io --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.28.128.4  --node-name=172.28.128.4
#集群
#kubeadm init --kubernetes-version=v1.18.0 --image-repository=localhost:5000/k8s.gcr.io --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.28.128.4  --node-name=172.28.128.4 --control-plane-endpoint "k8s-2:6444" --upload-certs | tee ~/abcd


mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


#在k8s运行docker regisgtry
docker stop docker-registry
RegistryName=docker-registry
sed -re "/hostPort: [0-9]+/s/[0-9]+/$DOCKER_REGISTRY_PORT/" $ROOT/k8s/$RegistryName.yaml > /etc/kubernetes/manifests/$RegistryName
until kubectl get pod docker-registry-$(hostname) ;do  sleep 3; done
#暴露为服务
#kubectl expose pod $RegistryName-$(hostname) --name=$RegistryName --type=NodePort  --overrides='{"apiVersion":"v1","spec":{"ports":[{"port":5000,"nodePort":'$DOCKER_REGISTRY_PORT'}]}}'


#运行calico
sed -r "/image/s|image: (.*)|image: $IP:$DOCKER_REGISTRY_PORT/\1|" $ROOT/k8s/calico.yaml \
| kubectl apply -f -


#运行nginx, 暴露yum源
yum install createrepo -y
createrepo $ROOT/yum
docker run --name nginx -d -p$NGINX_PORT:80 -v$ROOT/yum:/usr/share/nginx/html/yum $IP:$DOCKER_REGISTRY_PORT/nginx


#运行tekton
./tekton/auto.sh

#运行helm
./helm/auto.sh

kubectl proxy --address=$IP --port=23756  --accept-hosts=.* &

#准备k8s环境
swapoff -a
sed -i '\|^[ \t]*/swapfile|s/.*/#&/' /etc/fstab

setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=permissive/' /etc/selinux/config

cat >> /etc/sysctl.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
modprobe br_netfilter
sysctl -p

hostnamectl set-hostname ${IP}


#安装docker
yum install -yC docker-ce-19.03.14-3

#配置docker
mkdir /etc/docker -p
sed -r -e "/insecure-registries/ s|\[(.*)\]|[\"${MASTER_IP}:${DOCKER_REGISTRY_PORT}\"]|" \
  ${RESOURCES_ROOT}/k8s/daemon.json > /etc/docker/daemon.json

systemctl enable --now docker


#安装kubelet kubeadm kubectl
#yum install -y kubelet kubeadm kubectl –disableexcludes=kubernetes
yum install -yC kubelet-1.18.8-0 kubeadm-1.18.8-0 kubectl-1.18.8-0
systemctl enable --now kubelet
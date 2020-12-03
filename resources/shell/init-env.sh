export RESOURCES_ROOT=/vagrant/resources
export PACKAGES_ROOT=/vagrant/packages

export JOIN_CMD_FILE=$RESOURCES_ROOT/shell/join.sh

#export MASTER_IP=
#export IP=
#export IP=$(ip -f inet a s eth0 | awk '/inet/{split($2,arry,"/");print arry[1];exit}')

#export POD_CIDR=

export DOCKER_REGISTRY_HOST=inner-docker-registry
export DOCKER_REGISTRY_PORT=5000
export NGINX_PORT=8080

#sed -i '/^PasswordAuthentication no/ s/.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
#systemctl restart sshd

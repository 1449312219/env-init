export ROOT=/home/vagrant/share

#export IP=$(ip -f inet a s eth0 | awk '/inet/{split($2,arry,"/");print arry[1];exit}')

export DOCKER_REGISTRY_PORT=5000
export NGINX_PORT=8080

export JOIN_CMD_FILE=$ROOT/join.sh

sed -i '/^PasswordAuthentication no/ s/.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
set -ex
set -o pipefail

. ./init-env.sh


#配置yum源
rm /etc/yum.repos.d/*.repo -rf
sed -r -e "/baseurl/ s|//[^/]*|//${MASTER_IP}:${NGINX_PORT}|" \
  ${RESOURCES_ROOT}/repos/local.repo > /etc/yum.repos.d/local.repo
yum makecache

export INSTALL_ONLY_LOCAL=false
bash ./init-k8s-context.sh


#运行k8s
until [ -e ${JOIN_CMD_FILE} ]; do sleep 3; done
bash -c "$(cat ${JOIN_CMD_FILE}) --apiserver-advertise-address=${IP}"
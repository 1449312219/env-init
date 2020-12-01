. ./init-env.sh


#配置yum源
rm /etc/yum.repos.d/*.repo -rf
sed "/baseurl/ s|//[^/]*|//$MASTER_IP:$NGINX_PORT|" $ROOT/repos/local.repo \
> /etc/yum.repos.d/local.repo
yum makecache


./init-k8s-context.sh


#运行k8s
until [ -e $JOIN_CMD_FILE ]; do sleep 3; done
bash -c "$(cat $JOIN_CMD_FILE)  --apiserver-advertise-address=$IP"
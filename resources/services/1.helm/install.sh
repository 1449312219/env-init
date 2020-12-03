# 安装helm
PKG=helm-v3.2.4-linux-amd64.tar.gz
HELM_DIR=${PACKAGES_ROOT}/elf/helm

tar -xvf ${HELM_DIR}/$PKG -C ${HELM_DIR}
mv ${HELM_DIR}/linux-amd64/helm /usr/bin/helm
rm ${HELM_DIR}/linux-amd64 -rf

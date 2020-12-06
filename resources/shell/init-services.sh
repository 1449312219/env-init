SERVICE_ROOT=${RESOURCES_ROOT}/services

cd ${SERVICE_ROOT}

for dir in $(find . -type d -regex '.*/[0-9]+\..+' \
| xargs -i basename {} | sort -t . -n -k 1,1); do
  if test ! -e ${dir}/install.sh; then
    echo ${SERVICE_ROOT}/${dir}/install.sh not exit. skip
    continue
  fi
  
  cd ${dir} >/dev/null
  bash install.sh
  cd - >/dev/null
done

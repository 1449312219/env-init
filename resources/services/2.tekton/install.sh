files=(pipeline-v0.15.2.yaml trigger-v0.7.0.yaml dashboard-v0.8.2.yaml)

function apply() {
  local file=$1
  sed -r "/@sha/ s|([-0-9a-zA-Z/:.]+)@[^\"]*|${MASTER_IP}:${DOCKER_REGISTRY_PORT}/\1|" ${file} \
  | kubectl apply -f -
}

for file in ${files[@]}; do
  apply ${file}
done

kubectl wait -n tekton-pipelines pod --all --for=condition=Ready

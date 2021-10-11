# Usage: kubesecret
#        kubesecret secret-name
function kubesecret() {
  if [ $# -eq 1 ]; then
    kubectl get secret $1 -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
  fi
}

# Usage: kubewatch
#        kubewatch stage-3
function kubewatch() {
  if [ $# -eq 0 ]; then
    watch -n 1 "kubectl get pods --all-namespaces"
  else
    watch -n 1 "kubectl get pods --all-namespaces | grep $1"
  fi
}

# Usage: kubepods
#        kubepods stage-3
function kubepods() {
  if [ $# -eq 0 ]; then
    kubectl get pods --all-namespaces
  else
    kubectl get pods --all-namespaces | grep $1
  fi
}

# Usage: kubebash stage-3 web uwsgi
#        kubebash stage-3 postgres
function kubebash() {
  namespace=$1
  namere=$2
  name=$(kubectl get pods -n $namespace | grep $namere | head -1 | grep -o '^\S\+')
  if [[ $# -gt 2 ]]; then
    container=$3
    echo 'Entering the' $container 'container on' $name 'in namespace' $namespace
    kubectl --namespace $namespace exec -it $name -c $container bash
  else
    echo 'Entering the default container on' $name 'in namespace' $namespace
    kubectl --namespace $namespace exec -it $name bash
  fi
}

# Usage: kubelogs stage-3 web uwsgi
#        kubelogs stage-3 postgres
function kubelogs() {
  namespace=$1
  namere=$2
  name=$(kubectl get pods -n $namespace | grep $namere | head -1 | grep -o '^\S\+')
  if [[ $# -gt 2 ]]; then
    container=$3
    echo 'Tailing logs from the' $container 'container on' $name 'in namespace' $namespace
    kubectl --namespace $namespace logs -f --tail 100 $name -c $container
  else
    echo 'Tailing logs from the default container on' $name 'in namespace' $namespace
    kubectl --namespace $namespace logs -f --tail 100 $name
  fi
}

# Only run if the user actually has kubectl installed
if (( ${+_comps[kubectl]} )); then
  kj() { kubectl "$@" -o json | jq; }
  kjx() { kubectl "$@" -o json | fx; }
  ky() { kubectl "$@" -o yaml | yh; }

  compdef kj=kubectl
  compdef kjx=kubectl
  compdef ky=kubectl
fi

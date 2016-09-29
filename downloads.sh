#!/bin/bash

RELEASES_DIR=$(pwd)/downloads
BINARY_DIR=$(pwd)/binaries
 
mkdir -p ${RELEASES_DIR}
mkdir -p ${BINARY_DIR}

DOCKER_VERSION=${DOCKER_VERSION:-"1.12.1"}

# Define flannel version to use.
FLANNEL_VERSION=${FLANNEL_VERSION:-"0.6.2"}

# Define etcd version to use.
ETCD_VERSION=${ETCD_VERSION:-"3.0.10"}

# Define k8s version to use.
K8S_VERSION=${K8S_VERSION:-"1.4.0"}

DOCKER_DOWNLOAD_URL=\
"https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz"

FLANNEL_DOWNLOAD_URL=\
"https://github.com/coreos/flannel/releases/download/v${FLANNEL_VERSION}/flannel-v${FLANNEL_VERSION}-linux-amd64.tar.gz"

ETCD_DOWNLOAD_URL=\
"https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz"

K8S_DOWNLOAD_URL=\
"https://github.com/kubernetes/kubernetes/releases/download/v${K8S_VERSION}/kubernetes.tar.gz"


function clean-up() {
  rm -rf ${RELEASES_DIR}
  rm -rf ${BINARY_DIR}
}

function download-releases() {
  rm -rf ${RELEASES_DIR}
  mkdir -p ${RELEASES_DIR}

  echo "Download flannel release v${FLANNEL_VERSION} ..."
  curl -L ${FLANNEL_DOWNLOAD_URL} -o ${RELEASES_DIR}/flannel.tar.gz

  echo "Download etcd release v${ETCD_VERSION} ..."
  curl -L ${ETCD_DOWNLOAD_URL} -o ${RELEASES_DIR}/etcd.tar.gz

  echo "Download kubernetes release v${K8S_VERSION} ..."
  curl -L ${K8S_DOWNLOAD_URL} -o ${RELEASES_DIR}/kubernetes.tar.gz

  echo "Download docker release v${DOCKER_VERSION} ..."
  curl -L ${DOCKER_DOWNLOAD_URL} -o ${RELEASES_DIR}/docker.tar.gz
}

function unpack-releases() {
  rm -rf ${BINARY_DIR}
  mkdir -p ${BINARY_DIR}/master/bin
  mkdir -p ${BINARY_DIR}/node/bin

  # flannel
  if [[ -f ${RELEASES_DIR}/flannel.tar.gz ]] ; then
    mkdir -p ${RELEASES_DIR}/flannel-v${FLANNEL_VERSION}
    tar xzf ${RELEASES_DIR}/flannel.tar.gz -C ${RELEASES_DIR}/flannel-v${FLANNEL_VERSION}
    cp ${RELEASES_DIR}/flannel-v${FLANNEL_VERSION}/flanneld ${BINARY_DIR}/master/bin
    cp ${RELEASES_DIR}/flannel-v${FLANNEL_VERSION}/flanneld ${BINARY_DIR}/node/bin
  fi

  # ectd
  if [[ -f ${RELEASES_DIR}/etcd.tar.gz ]] ; then
    tar xzf ${RELEASES_DIR}/etcd.tar.gz -C ${RELEASES_DIR}
    ETCD="etcd-v${ETCD_VERSION}-linux-amd64"
    cp ${RELEASES_DIR}/$ETCD/etcd \
       ${RELEASES_DIR}/$ETCD/etcdctl ${BINARY_DIR}/master/bin
    cp ${RELEASES_DIR}/$ETCD/etcd \
       ${RELEASES_DIR}/$ETCD/etcdctl ${BINARY_DIR}/node/bin
  fi

  # k8s
  if [[ -f ${RELEASES_DIR}/kubernetes.tar.gz ]] ; then
    tar xzf ${RELEASES_DIR}/kubernetes.tar.gz -C ${RELEASES_DIR}

    pushd ${RELEASES_DIR}/kubernetes/server
    tar xzf kubernetes-server-linux-amd64.tar.gz
    popd
    cp ${RELEASES_DIR}/kubernetes/server/kubernetes/server/bin/kube-apiserver \
       ${RELEASES_DIR}/kubernetes/server/kubernetes/server/bin/kube-controller-manager \
       ${RELEASES_DIR}/kubernetes/server/kubernetes/server/bin/kube-scheduler ${BINARY_DIR}/master/bin

    cp ${RELEASES_DIR}/kubernetes/server/kubernetes/server/bin/kubelet \
       ${RELEASES_DIR}/kubernetes/server/kubernetes/server/bin/kube-proxy ${BINARY_DIR}/node/bin

    cp ${RELEASES_DIR}/kubernetes/server/kubernetes/server/bin/kubectl ${BINARY_DIR}
  fi

  # docker
  if [[ -f ${RELEASES_DIR}/docker.tar.gz ]]; then
    tar xzf ${RELEASES_DIR}/docker.tar.gz -C ${RELEASES_DIR}

    cp ${RELEASES_DIR}/docker/docker* ${BINARY_DIR}/node/bin
  fi

  chmod -R +x ${BINARY_DIR}
  echo "Done! All binaries are stored in ${BINARY_DIR}"
}

function parse-opt() {
  local opt=${1-}

  case $opt in
    download)
      download-releases
      ;;
    unpack)
      unpack-releases
      ;;
    clean)
      clean-up
      ;;
    all)
      download-releases
      unpack-releases
      ;;
    *)
      echo "Usage: "
      echo "   build.sh <command>"
      echo "Commands:"
      echo "   clean      Clean up downloaded releases and unpacked binaries."
      echo "   download   Download releases to \"${RELEASES_DIR}\"."
      echo "   unpack     Unpack releases downloaded in \"${RELEASES_DIR}\", and copy binaries to \"${BINARY_DIR}\"."
      echo "   all        Download releases and unpack them."
      ;;
  esac
}

parse-opt $@


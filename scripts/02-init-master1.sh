#!/bin/bash
cd "$(dirname "$0")/.."
source config.env

if [[ "$NODE_ROLE" != "master1" ]]; then
  echo "[-] 仅 master1 可运行此脚本。"
  exit 1
fi

echo "[+] 初始化第一个 Master 节点..."

kubeadm init \
  --control-plane-endpoint="${VIP}:6443" \
  --upload-certs \
  --kubernetes-version=${K8S_VERSION} \
  --pod-network-cidr=${POD_CIDR} \
  --service-cidr=${SERVICE_CIDR}

mkdir -p $HOME/.kube
cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 安装 Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# 保存 join 命令
kubeadm token create --print-join-command > $JOIN_CMD_FILE
CERT_KEY=$(kubeadm init phase upload-certs --upload-certs --config /etc/kubernetes/kubeadm-config.yaml 2>/dev/null | tail -1)
echo "$CERT_KEY" > $CERT_KEY_FILE

echo "[✓] Master1 初始化完成！"
echo "请将以下文件复制到其他节点："
echo "  $JOIN_CMD_FILE"
echo "  $CERT_KEY_FILE"

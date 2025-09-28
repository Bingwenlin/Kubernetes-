#!/bin/bash
cd "$(dirname "$0")/.."
source config.env

if [[ "$NODE_ROLE" == "master1" ]] || [[ "$NODE_ROLE" == node* ]]; then
  echo "[-] 仅 master2/master3 可运行此脚本。"
  exit 1
fi

if [[ ! -f "$JOIN_CMD_FILE" ]] || [[ ! -f "$CERT_KEY_FILE" ]]; then
  echo "[-] 缺少 join 命令或证书密钥文件，请从 master1 拷贝。"
  exit 1
fi

JOIN_CMD=$(cat $JOIN_CMD_FILE)
CERT_KEY=$(cat $CERT_KEY_FILE)

echo "[+] 加入 Master 节点..."

$JOIN_CMD --control-plane --certificate-key "$CERT_KEY"

mkdir -p $HOME/.kube
scp master1:$HOME/.kube/config $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[✓] Master 节点加入成功！"

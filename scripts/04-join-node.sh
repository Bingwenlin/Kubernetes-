#!/bin/bash
cd "$(dirname "$0")/.."
source config.env

if ! [[ "$NODE_ROLE" == node* ]]; then
  echo "[-] 仅 Worker 节点可运行此脚本。"
  exit 1
fi

if [[ ! -f "$JOIN_CMD_FILE" ]]; then
  echo "[-] 缺少 join 命令，请从 master1 拷贝 $JOIN_CMD_FILE"
  exit 1
fi

echo "[+] 加入 Worker 节点..."
$(cat $JOIN_CMD_FILE)

echo "[✓] Node 加入成功！"

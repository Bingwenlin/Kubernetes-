# Kubernetes高可用集群自动化部署


# 部署包架构
k8s-ha-deploy/
├── config.env                 # 全局配置文件（IP、VIP、版本等）
├── scripts/
│   ├── 00-common-init.sh      # 所有节点通用初始化
│   ├── 01-ha-setup.sh        # Master 节点部署 HAProxy + Keepalived
│   ├── 02-init-master1.sh    # 初始化第一个 Master
│   ├── 03-join-master.sh     # 加入其他 Master 节点
│   ├── 04-join-node.sh       # 加入 Worker 节点
│   └── utils.sh              # 工具函数（如自动检测角色）
├── manifests/
│   └── calico.yaml           # Calico CNI（可选离线）
└── README.md                 # 部署说明


# Kubernetes 高可用集群部署包（3 Master + 3 Node）

## 使用步骤

1. **修改 `config.env`**  
   设置你的 IP 地址、VIP、K8S 版本等。

2. **分发部署包到所有 6 台机器**  
   ```bash
   tar -czvf k8s-ha-deploy.tar.gz k8s-ha-deploy/
   scp k8s-ha-deploy.tar.gz user@host:/tmp/

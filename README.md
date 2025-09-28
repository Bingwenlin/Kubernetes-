# Kubernetes高可用集群自动化部署


# 部署包架构
```
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
```

# Kubernetes 高可用集群部署包（3 Master + 3 Node）

## 使用步骤

1. **修改 `config.env`**  
   设置你的 IP 地址、VIP、K8S 版本等。

2. **分发部署包到所有 6 台机器**  
   ```bash
   tar -czvf k8s-ha-deploy.tar.gz k8s-ha-deploy/
   scp k8s-ha-deploy.tar.gz user@host:/tmp/
在每台机器上解压并设置角色
```Bash
编辑
tar -xzvf k8s-ha-deploy.tar.gz
cd k8s-ha-deploy



# 编辑 config.env，设置 NODE_ROLE 为 master1/master2/.../node3
按顺序执行脚本
所有节点：bash scripts/00-common-init.sh
所有 Master：bash scripts/01-ha-setup.sh
master1：bash scripts/02-init-master1.sh
master2/3：拷贝 /tmp/k8s-join-cmd.sh 和 /tmp/k8s-cert-key.txt 后运行 scripts/03-join-master.sh
所有 Node：拷贝 /tmp/k8s-join-cmd.sh 后运行 scripts/04-join-node.sh

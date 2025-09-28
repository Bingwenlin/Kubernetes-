#!/bin/bash
cd "$(dirname "$0")/.."
source config.env
source scripts/utils.sh

set -e

echo "[+] 正在执行通用初始化..."

# 自动设置网卡
if [[ -z "$INTERFACE" ]]; then
  INTERFACE=$(detect_interface)
  echo "自动检测网卡: $INTERFACE"
fi

# 关闭防火墙
systemctl stop firewalld 2>/dev/null || ufw disable 2>/dev/null || true
systemctl disable firewalld 2>/dev/null || true

# 关闭 SELinux
setenforce 0 2>/dev/null || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config 2>/dev/null || true

# 关闭 swap
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# 配置 hosts
cat > /etc/hosts <<EOF
127.0.0.1   localhost
${MASTER1_IP} master1
${MASTER2_IP} master2
${MASTER3_IP} master3
${NODE1_IP} node1
${NODE2_IP} node2
${NODE3_IP} node3
${VIP} k8s-vip
EOF

# 内核模块
cat > /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
EOF
modprobe br_netfilter

# sysctl
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

# 安装 containerd
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y containerd.io
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# 添加 Kubernetes repo
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# 安装 k8s 组件
yum install -y kubelet-${K8S_VERSION#v} kubeadm-${K8S_VERSION#v} kubectl-${K8S_VERSION#v} --disableexcludes=kubernetes
systemctl enable --now kubelet

echo "[✓] 通用初始化完成！"

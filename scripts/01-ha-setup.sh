#!/bin/bash
cd "$(dirname "$0")/.."
source config.env
source scripts/utils.sh

if ! is_master; then
  echo "[-] 仅 Master 节点可运行此脚本。"
  exit 1
fi

echo "[+] 部署 HAProxy + Keepalived..."

yum install -y haproxy keepalived

# HAProxy 配置
cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon

defaults
    mode tcp
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend k8s-api
    bind ${VIP}:6443
    default_backend k8s-masters

backend k8s-masters
    balance roundrobin
    server master1 ${MASTER1_IP}:6443 check
    server master2 ${MASTER2_IP}:6443 check
    server master3 ${MASTER3_IP}:6443 check
EOF

systemctl enable --now haproxy

# Keepalived 配置
cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_script chk_haproxy {
    script "killall -0 haproxy"
    interval 2
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state $(get_state)
    interface ${INTERFACE}
    virtual_router_id 51
    priority $(get_priority)
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass k8sHA123
    }
    virtual_ipaddress {
        ${VIP}/${NETMASK}
    }
    track_script {
        chk_haproxy
    }
}
EOF

systemctl enable --now keepalived

echo "[✓] HAProxy + Keepalived 部署完成！"

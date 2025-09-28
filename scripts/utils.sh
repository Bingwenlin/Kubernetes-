# k8s-ha-deploy/scripts/utils.sh

detect_interface() {
  ip route | grep default | awk '{print $5}' | head -1
}

is_master() {
  [[ "$NODE_ROLE" == master* ]]
}

get_priority() {
  case "$NODE_ROLE" in
    master1) echo 100 ;;
    master2) echo 90 ;;
    master3) echo 80 ;;
    *) echo 50 ;;
  esac
}

get_state() {
  [[ "$NODE_ROLE" == "master1" ]] && echo "MASTER" || echo "BACKUP"
}

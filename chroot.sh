#!/usr/bin/env bash
#
# Post install
set -e -o pipefail

setup_services() {
  systemctl enable \
    NetworkManager \
    systemd-timesyncd bluetooth fstrim.timer

  systemctl mask NetworkManager-wait-online
}

setup_system() {
  local password="${1}"
  local user_name='foo'

  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  hwclock -w --utc

  usermod --lock -s /usr/bin/nologin root
  useradd --create-home -G wheel,video -s /usr/bin/bash "${user_name}"
  echo "${user_name}:${password}" | chpasswd

  pacman -Scc --noconfirm
}

main() {
  local password="${1}"

  echo '- chroot'
  tar --uid 0 --gid 0 -x -f /mnt/cfg.tar -C /
  setup_system "${password}"
  setup_services
  bootctl install --esp-path=/boot
}

main "${1}"

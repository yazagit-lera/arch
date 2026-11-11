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

  tar --uid 0 --gid 0 -x -f /mnt/cfg.tar -C /
  pacman -Scc --noconfirm
  #bootctl install --esp-path=/boot

  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  hwclock -w --utc

  usermod --lock -s /usr/bin/nologin root
  useradd --create-home -G wheel,video -s /usr/bin/bash "${user_name}"
  echo "${user_name}:${password}" | chpasswd
}

main() {
  local password="${1}"

  setup_system "${password}"
  setup_services
}

main "${1}"

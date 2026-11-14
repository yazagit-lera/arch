#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Post install
set -e -o pipefail

configure_services() {
    systemctl enable \
        NetworkManager gdm systemd-timesyncd bluetooth fstrim.timer

    systemctl mask NetworkManager-wait-online
}

configure_system() {
  local password="${1}"
  local user_name='sakikasa'

  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  hwclock -w --utc

  tar --uid 0 --gid 0 -x -f /mnt/cfg.tar -C /
  pacman -Scc --noconfirm
  bootctl install --esp-path=/boot

  usermod --lock -s /usr/bin/nologin root
  cp /etc/skel/.bashrc /root

  useradd --create-home -G wheel,video -s /usr/bin/bash "${user_name}"
  echo "${user_name}:${password}" | chpasswd
}

main() {
  local password="${1}"

  configure_system "${password}"
  configure_services
}

main "${1}"

#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# chroot configuration
set -e -o pipefail

configure_services() {
    systemctl enable \
        NetworkManager gdm systemd-timesyncd bluetooth fstrim.timer

    systemctl mask NetworkManager-wait-online
}

configure_system() {
    local password="${1}"
    local user_name='sakikasa'

    umask 022
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    hwclock -uw

    cp -Tr --no-preserve=mode /mnt/root /
    pacman -Scc --noconfirm
    bootctl install --esp-path=/boot

    usermod --lock -s /usr/bin/nologin root
    install -m 640 -o root -g root /etc/skel/.bashrc /root
    chmod 400 /etc/doas.conf

    useradd -m -G wheel,audio,video -s /usr/bin/bash "${user_name}"
    echo "${user_name}:${password}" | chpasswd
}

main() {
    local password="${1}"

    configure_system "${password}"
    configure_services
}

main "${1}"

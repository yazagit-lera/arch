#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# chroot configuration
set -e -o pipefail

configure_services() {
    systemctl enable \
        NetworkManager gdm systemd-timesyncd bluetooth \
        nftables systemd-oomd tlp fstrim.timer

    systemctl mask NetworkManager-wait-online
}

configure_system() {
    local password="${1}"
    local user_name='sakikasa'

    umask 022
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    hwclock -uw

    cp -TR --no-preserve=mode /mnt/root /
    pacman -Scc --noconfirm
    bootctl install --esp-path=/boot

    usermod --lock -s /usr/bin/nologin root
    install -m 600 -o root -g root /etc/skel/.bashrc /etc/skel/.inputrc /root
    chmod -R 755 /usr/local/bin
    chmod 400 /etc/doas.conf
    
    useradd -m -G wheel,video -s /usr/bin/bash "${user_name}"
    echo "${user_name}:${password}" | chpasswd
}

main() {
    local password="${1}"

    configure_system "${password}"
    configure_services
}

main "${1}"

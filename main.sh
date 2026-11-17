#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Install arch linux
set -e -o pipefail

setup_pacman() {
    local path="${1}/root/etc"

    cp "${path}/pacman.conf" /etc
    cp "${path}/pacman.d/mirrorlist" /etc

    pacman-key --init
    pacman-key --populate archlinux
    pacman -Syy archlinux-keyring --noconfirm
}

format_disk() {
    local block='nvme0n1'
    local disk='/dev/nvme0n1'
    local efi='/dev/nvme0n1p1'
    local root='/dev/nvme0n1p2'

    mountpoint -q /mnt && umount -R /mnt
    echo 'kyber' > "/sys/block/${block}/queue/scheduler"

    blkdiscard -vf "${disk}"
    sgdisk -Zo \
        -n1:0:+512M -t1:ef00 -c1:'EFI System Partition' \
        -n2:0:0 -t2:8304 -c2:'Arch Linux Root' -p "${disk}"
    udevadm wait "${efi}" "${root}"

    mkfs.fat -F32 -n ESP -v --codepage=437 "${efi}"
    mke2fs -t ext4 -vF -m1 -L arch -E nodiscard "${root}"

    local root_options='noatime,nodiscard,journal_checksum'
    local efi_options
    efi_options='noexec,nodev,nosuid,noatime,fmask=0177,dmask=0077'
    efi_options+=',nosymfollow,X-mount.mkdir=600'

    mount -t ext4 -v -o "${root_options}" "${root}" /mnt
    mount -t vfat -v -o  "${efi_options}" "${efi}" /mnt/boot
}

post_install() {
    local password="${1}"

    mount -o bind,ro -v /tmp/arch /mnt/mnt
    arch-chroot /mnt bash /mnt/chroot.sh "${password}"
    umount -v /mnt/mnt
}

end() {
    umount -vR /mnt
    systemctl poweroff
}

main() {
    local password="${1}"
    local tmp_dir="${2}"

    setup_pacman "${tmp_dir}"
    format_disk
    pacstrap /mnt $(cat "${tmp_dir}/packages")
    post_install "${password}"
    end
}

main "${1}" "${2}"

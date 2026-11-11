#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Install arch linux
set -e -o pipefail

setup_pacman() {
  local pacmanconf
  pacmanconf='https://raw.githubusercontent.com/nedorazrab0/arch39/main/cfg'
  pacmanconf="${pacmanconf}/etc/pacman.conf"
  curl -f -o /etc/pacman.conf -- "${pacmanconf}"

  local mirrorconf
  mirrorconf='https://raw.githubusercontent.com/nedorazrab0/arch39/main/cfg'
  mirrorconf="${mirrorconf}/etc/pacman.d/mirrorlist"
  curl -f -o /etc/pacman.d/mirrorlist -- "${mirrorconf}"

  pacman-key --init
  pacman-key --populate archlinux
  pacman -Syy archlinux-keyring --needed --noconfirm
}

disk_partition() {
  local block='nvme0n1'
  local disk='/dev/nvme0n1'
  local efi='/dev/nvme0n1p2'
  local root='/dev/nvme0n1p2'

  mountpoint -q /mnt && umount -R /mnt

  echo 'none' > "/sys/block/${block}/queue/scheduler"
  echo '128' > "/sys/block/${block}/queue/nr_requests"
  echo '2' > "/sys/block/${block}/queue/rq_affinity"

  wipefs -a "${disk}"
  blkdiscard -vf "${disk}"
  sgdisk -Zo \
    -n1:0:+512M -t1:ef00 -c1:'EFI System Partition' \
    -n2:0:0 -t2:8304 -c2:'Arch Linux Root' -p "${disk}"

  mkfs.fat -F32 -n ESP -v --codepage=437 "${efi}"
  mkfs.btrfs -fK -L archlinux --csum xxhash "${root}"

  local btrfs_options
  btrfs_options='noatime,nodiscard,nobarrier,commit=300,lazytime,ssd'
  btrfs_options+='compress-force=zstd:3'

  local fat_options
  fat_options='noexec,nodev,nosuid,noatime,fmask=0177,dmask=0077'
  fat_options+='lazytime,X-mount.mkdir=600'

  mount -t btrfs -v -o "${btrfs_options}" "${efi}" /mnt
  mount -t vfat -v -o  "${fat_options}" "${root}" /mnt/boot
}

bootstrap() {
  pacstrap /mnt base linux booster amd-ucode \
    exfatprogs dosfstools android-tools \
    flatpak zram-generator nano python mandoc less \
    unzip polkit \
    ghostty doas \
    xdg-user-dirs \
    vulkan-radeon mesa vulkan-mesa-layers bluez{,-utils} \
    iptables adwaita-fonts pipewire{,-pulse,-jack} \
    gnome-shell ${fwpkglist}
}

post_install() {
  local password="${1}"

  mount -o bind,ro -v /tmp/arch39 /mnt/mnt
  arch-chroot /mnt bash /mnt/chroot.sh "${password}"
  umount -v /mnt/mnt
}

end() {
  umount -vR /mnt
  systemctl poweroff
}

main() {
  local password
  password="$(ask-password)"

  setup_pacman
  disk_partition "${blk}"
  pkg_strap "${fwlist}"
  setup_chroot "${username}" "${password}" "${timezone}" "${layout}"
  end
}

main "${@}"

#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Download the installer
set -e -o pipefail

main() {
    local tmp_dir='/tmp/arch'

    if [[ ! -d '/run/archiso' ]]; then
        echo '! Invalid archiso'
        exit 1
    fi

    [[ -d "${tmp_dir}" ]] && rm -rf "${tmp_dir}"
    mkdir -p -- "${tmp_dir}"

    local archive
    archive='https://github.com/yazagit-lera/arch/releases/download'
    archive+='/rolling/arch.tar.lz4'

    curl -fL "${archive}" | lz4 -dvc | tar -x -C "${tmp_dir}"
    local password
    password="$(systemd-ask-password --echo=no --emoji=no 'New password:')"
    bash "${tmp_dir}/main.sh" "${password}"
}

main

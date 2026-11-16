#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Create the release archive
set -e -o pipefail

main() {
    chmod -R 755 ./cfg/usr/local/bin
    tar -b1 -cv -C ./root -f ./root.tar .
    rm -rf ./root

    tar --exclude-vcs --exclude=./{.github/,README.md} -b1 -cv ./* \
        | lz4 -zvc > ./arch.tar.lz4
}

main

#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Create the release archive
set -e -o pipefail

main() {
    tar --exclude-vcs --exclude=./{.github/,README.md} -b1 -cv ./* \
        | lz4 -zvc > ./arch.tar.lz4
}

main

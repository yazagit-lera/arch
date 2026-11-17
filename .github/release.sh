#!/usr/bin/env bash
# SPDX-License-Identifier: 0BSD
# Create a new release
set -e -o pipefail

main() {
    gh release delete rolling --cleanup-tag -y || true
    gh release create rolling ./arch.tar.zst --generate-notes
}

main

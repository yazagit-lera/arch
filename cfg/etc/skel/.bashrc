# SPDX-License-Identifier: 0BSD
# bash config

main() {
    PS1='\[\033[33m\]\$ \W/ \[\033[34m\]${?}\[\033[0m\]\n'
}

main

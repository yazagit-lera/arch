# SPDX-License-Identifier: 0BSD
# bash config

main() {
    PS1='\[\e[33m\]\$ \W/ \[\e[34m\]${?}\[\e[0m\]\n'
    complete -cf doas
}

main

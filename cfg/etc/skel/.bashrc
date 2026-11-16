# SPDX-License-Identifier: 0BSD
# bash config

main() {
    [[ "${-}" =~ 'i' ]] || return
    PS1='\[\033[33m\]\$ ${?} \W\[\033[0m\]\n'
}

main

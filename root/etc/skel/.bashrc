# SPDX-License-Identifier: 0BSD
# bash config

main() {
    PS1='\[\e[33m\]\$ \W/ \[\e[34m\]${?}\[\e[0m\]\n'
    bind 'set blink-matching-paren on'
    bind 'set page-completions off'
    bind 'TAB: menu-complete'
    complete -cf doas
}

main

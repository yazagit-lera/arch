# SPDX-License-Identifier: 0BSD
# bash config

main() {
    PS1='\[\033[33m\]\$ \W/ \[\033[34m\]${?}\[\033[0m\]\n'
    bind 'set blink-matching-paren on'
    bind 'set page-completions off'
    bind 'TAB: menu-complete'
}

main

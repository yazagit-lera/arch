# SPDX-License-Identifier: 0BSD
# bash config

main() {
    local color='\033[33m'
    local default_color='\033[0m'
    PS1="\[${color}\]\$ \W \${?}\[${default_color}\]\n"
}

main

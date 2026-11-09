# SPDX-License-Identifier: 0BSD
# bash config

main() {
    local color='\x1b[38;2;225;221;68m'
    local default_color='\x1b[0m'
    PS1="\[${color}\]\$ \W $?\[${default_color}\]\n"
}

main

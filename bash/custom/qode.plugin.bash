# shellcheck shell=bash
# qode — the template's own bash-it plugin. bash-it sources every $BASH_IT_CUSTOM/*.bash.
cite about-plugin
about-plugin 'qode template helpers'

function qode_hello() {
	about 'print a greeting from the qode setup'
	group 'qode'
	printf '%s\n' "hello from qode"
}

# mkcd DIR — make a directory and cd into it
function mkcd() {
	about 'make a directory and cd into it'
	param '1: directory'
	group 'qode'
	mkdir -p -- "$1" && cd -- "$1" || return
}

alias ll='ls -lah'

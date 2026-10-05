# shellcheck shell=bash
# qode theme — a small prompt: "qode <cwd> <git>$". Uses bash-it's colour and scm helpers,
# and registers itself the way the bundled themes do. Loaded from
# $BASH_IT_CUSTOM/themes/qode/qode.theme.bash by BASH_IT_THEME=qode.

SCM_THEME_PROMPT_PREFIX=" ${purple?}("
SCM_THEME_PROMPT_SUFFIX=")${normal?}"
SCM_THEME_PROMPT_DIRTY="*"
SCM_THEME_PROMPT_CLEAN=""

function _qode_prompt_command() {
	local status=$?
	local mark="${green?}\$${normal?}"
	((status != 0)) && mark="${red?}\$${normal?}"
	PS1="${bold_cyan?}qode${normal?} ${bold_blue?}\w${normal?}$(scm_prompt_info) ${mark} "
}

safe_append_prompt_command _qode_prompt_command

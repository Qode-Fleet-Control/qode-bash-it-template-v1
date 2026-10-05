# .bashrc — the versioned bash setup this repo ships, on bash-it. bash-it lives in
# $BASH_IT; everything custom (plugin, theme) lives next to this file in ./custom.
case $- in *i*) ;; *) return ;; esac   # interactive shells only

_qode_rc_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
QODE_BASH_VERSION="$(<"$_qode_rc_dir/../VERSION")"

export BASH_IT="${BASH_IT:-$HOME/.bash_it}"
export BASH_IT_CUSTOM="$_qode_rc_dir/custom"   # custom/*.bash is sourced; themes in custom/themes
export BASH_IT_THEME="qode"

# A pinned install: no update nags, no remote git status checks in the prompt.
export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=''
export SCM_CHECK=true
export SCM_GIT_SHOW_REMOTE_INFO=false

source "$BASH_IT/bash_it.sh"
BASH_IT_VERSION_TAG="$(git -C "$BASH_IT" describe --tags 2>/dev/null || echo unknown)"

# --- user configuration -----------------------------------------------------------
export EDITOR="${EDITOR:-vi}"

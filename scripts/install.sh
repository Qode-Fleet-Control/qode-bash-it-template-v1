#!/usr/bin/env bash
# Install bash-it the way its README teaches — clone, then its own install.sh — pinned to
# a release tag, into $BASH_IT (default ~/.bash_it).
#
#   install.sh --silent --no-modify-config
#     --silent            enable bash-it's "default" profile without prompting
#     --no-modify-config  leave ~/.bashrc alone: this repo's bash/.bashrc loads bash-it
#
# Then enables the extra components this setup uses. Used by the Dockerfile and fleet.conf.
set -euo pipefail
BASH_IT_REF="${BASH_IT_REF:-v3.2.0}"
here=$(cd "$(dirname "$0")/.." && pwd)
export BASH_IT="${BASH_IT:-$HOME/.bash_it}"

if [[ ! -d $BASH_IT/.git ]]; then
  git -c advice.detachedHead=false clone -q --depth=1 --branch "$BASH_IT_REF" \
    https://github.com/Bash-it/bash-it.git "$BASH_IT"
  "$BASH_IT/install.sh" --silent --no-modify-config
fi

# components on top of the default profile — through bash-it's own CLI, in an
# interactive bash loaded with this repo's .bashrc
bash --rcfile "$here/bash/.bashrc" -i -c '
  bash-it enable plugin git
  bash-it enable alias git
' 2>&1 | grep -v -x 'exit' | grep -v -e 'no job control in this shell' -e 'cannot set terminal process group' || true

echo "bash-it $(git -C "$BASH_IT" describe --tags) in $BASH_IT"

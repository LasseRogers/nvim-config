# shellcheck shell=bash
# Sourced from ~/.bashrc.

[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim

alias vim=nvim
alias lg=lazygit

# Debian ships fd as fdfind.
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd=fdfind

if command -v fzf >/dev/null 2>&1; then
  if fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    # fzf < 0.48 (Debian/Ubuntu apt) has no --bash flag.
    # shellcheck source=/dev/null
    . /usr/share/doc/fzf/examples/key-bindings.bash
  fi
fi

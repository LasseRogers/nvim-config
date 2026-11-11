#!/usr/bin/env bash
#
# Bootstrap for Debian/Ubuntu and Apple Silicon macOS. Idempotent.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
ARCH="$(uname -m)"

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# Tries the API first, then the /releases/latest redirect (no rate limit).
latest_tag() {
  local tag
  tag="$(curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null |
    grep -m1 '"tag_name"' | cut -d'"' -f4)" || true
  if [ -z "$tag" ]; then
    tag="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" 2>/dev/null |
      sed -n 's|.*/tag/||p')" || true
  fi
  echo "$tag"
}

install_macos() {
  [ "$ARCH" = arm64 ] || die "only Apple Silicon is supported"

  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  log "brew bundle"
  brew bundle --file "$REPO/Brewfile"

  # /bin/bash on macOS is 3.2.
  local brew_bash
  brew_bash="$(brew --prefix)/bin/bash"
  if ! grep -qx "$brew_bash" /etc/shells; then
    log "Adding $brew_bash to /etc/shells"
    echo "$brew_bash" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "$SHELL" != "$brew_bash" ]; then
    log "Setting login shell to $brew_bash"
    chsh -s "$brew_bash"
  fi

  # Terminal apps on macOS start login shells, which only read ~/.bash_profile.
  touch "$HOME/.bash_profile"
  grep -q '.bashrc' "$HOME/.bash_profile" ||
    echo '[ -f ~/.bashrc ] && . ~/.bashrc' >>"$HOME/.bash_profile"
}

install_debian() {
  command -v apt-get >/dev/null 2>&1 || die "only apt-based distributions are supported"

  local sudo=""
  [ "$(id -u)" -eq 0 ] || sudo="sudo"

  log "apt packages"
  $sudo apt-get update
  $sudo apt-get install -y \
    git curl unzip build-essential \
    ripgrep fd-find fzf \
    nodejs npm python3-venv \
    xclip wl-clipboard \
    tmux bc gawk \
    stow fontconfig

  local nvim_arch ts_arch lg_arch
  case "$ARCH" in
    x86_64) nvim_arch=x86_64 ts_arch=x64 lg_arch=x86_64 ;;
    aarch64 | arm64) nvim_arch=arm64 ts_arch=arm64 lg_arch=arm64 ;;
    *) die "unsupported architecture: $ARCH" ;;
  esac

  # apt's neovim is too old for this config.
  log "Neovim (latest release)"
  rm -rf "$HOME/.local/opt/nvim"
  mkdir -p "$HOME/.local/opt/nvim"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" |
    tar xz -C "$HOME/.local/opt/nvim" --strip-components=1
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"

  log "tree-sitter CLI"
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$ts_arch.gz" |
    gunzip >"$HOME/.local/bin/tree-sitter"
  chmod +x "$HOME/.local/bin/tree-sitter"

  if ! command -v lazygit >/dev/null 2>&1; then
    log "lazygit"
    local tag
    tag="$(latest_tag jesseduffield/lazygit)"
    if [ -z "$tag" ] || ! curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$tag/lazygit_${tag#v}_Linux_$lg_arch.tar.gz" |
      tar xz -C "$HOME/.local/bin" lazygit; then
      warn "lazygit download failed, skipping"
    fi
  fi

  if ! fc-list | grep -qi "JetBrainsMono Nerd Font Mono"; then
    log "JetBrainsMono Nerd Font"
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/font.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
    # Mono variant only. VTE-based terminals render the others with wide letter spacing.
    unzip -oq "$tmp/font.zip" 'JetBrainsMonoNerdFontMono-*' -d "$HOME/.local/share/fonts/JetBrainsMono"
    rm -rf "$tmp"
    fc-cache -f >/dev/null
  fi
}

link() {
  log "Linking configs"
  local packages=(nvim tmux bash)
  [ "$OS" = Darwin ] && packages+=(ghostty)

  # Anything in the way that isn't already ours gets moved aside; dangling links are removed.
  local stamp f target
  stamp="$(date +%Y%m%d-%H%M%S)"
  for f in .config/nvim .tmux.conf .config/bash/rc.sh .config/ghostty/config; do
    target="$HOME/$f"
    if [ -L "$target" ] && [[ "$(readlink -f "$target" 2>/dev/null)" == "$REPO"/* ]]; then
      continue
    elif [ -L "$target" ] && [ ! -e "$target" ]; then
      rm "$target"
    elif [ -e "$target" ] || [ -L "$target" ]; then
      echo "backup: ~/$f -> ~/$f.bak-$stamp"
      mv "$target" "$target.bak-$stamp"
    fi
  done

  mkdir -p "$HOME/.config/bash" "$HOME/.config/ghostty"
  stow -d "$REPO" -t "$HOME" --restow "${packages[@]}"

  touch "$HOME/.bashrc"
  grep -q '.config/bash/rc.sh' "$HOME/.bashrc" ||
    echo '[ -f ~/.config/bash/rc.sh ] && . ~/.config/bash/rc.sh' >>"$HOME/.bashrc"
}

tmux_plugins() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  log "tmux plugins"
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || true
}

nvim_plugins() {
  log "Neovim plugins"
  nvim --headless "+Lazy! sync" +qa
}

case "$OS" in
  Darwin) install_macos ;;
  Linux) install_debian ;;
  *) die "unsupported OS: $OS" ;;
esac

link
tmux_plugins
nvim_plugins

log "Done"
echo "Open a new shell and run nvim. LSP servers and parsers install on first launch."
[ "$OS" = Linux ] && echo "Set your terminal font to JetBrainsMono Nerd Font Mono."
exit 0

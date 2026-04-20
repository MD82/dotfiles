#!/bin/bash
set -e

DOTFILES="$HOME/.dotfiles"

# OS 감지
detect_os() {
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl"
  elif [ "$(uname -s)" = "Darwin" ]; then
    echo "macos"
  elif grep -qi cachyos /etc/os-release 2>/dev/null; then
    echo "cachyos"
  elif grep -qi arch /etc/os-release 2>/dev/null; then
    echo "arch"
  else
    echo "unknown"
  fi
}

OS=$(detect_os)
echo "Detected OS: $OS"

# 심링크 생성 함수 (기존 파일은 백업)
link() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  # Replace the symlink itself even when dst is a symlink to a directory.
  ln -sfnT "$src" "$dst"
  echo "  Linked: $dst"
}

link_dir() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sfnT "$src" "$dst"
  echo "  Linked: $dst -> $src"
}

# 공통
link "$DOTFILES/tmux/.tmux.conf"             "$HOME/.tmux.conf"
link "$DOTFILES/nvim/.config/nvim"           "$HOME/.config/nvim"
link "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/git/.config/git/ignore"      "$HOME/.config/git/ignore"

# Shell
link "$DOTFILES/shell/.bash_aliases" "$HOME/.bash_aliases"

# Hyprland (CachyOS / Arch)
if [ "$OS" = "cachyos" ] || [ "$OS" = "arch" ]; then
  if [ -d "$DOTFILES/hyprland/.config/hypr" ]; then
    link "$DOTFILES/hyprland/.config/hypr" "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/hypr/conf"
    link_dir "$DOTFILES/hyprland/.config/hypr/conf/$OS" "$HOME/.config/hypr/conf/current"
  fi
fi

# Waybar (Arch만)
if [ "$OS" = "arch" ]; then
  if [ -d "$DOTFILES/waybar/.config/waybar" ]; then
    link "$DOTFILES/waybar/.config/waybar" "$HOME/.config/waybar"
  fi
fi

# Quickshell (CachyOS만)
if [ "$OS" = "cachyos" ]; then
  if [ -d "$DOTFILES/quickshell/.config/quickshell" ]; then
    link "$DOTFILES/quickshell/.config/quickshell" "$HOME/.config/quickshell"
  fi
fi

echo ""
echo "Done! dotfiles linked for: $OS"

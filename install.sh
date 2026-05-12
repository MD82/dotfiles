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
    local bak="$dst.bak"
    local n=1
    while [ -e "$bak" ]; do
      bak="$dst.bak.$n"
      n=$((n + 1))
    done
    echo "  Backing up $dst → $bak"
    mv "$dst" "$bak"
  fi
  # Replace the symlink itself even when dst is a symlink to a directory.
  if [ -L "$dst" ]; then
    rm "$dst"
  fi
  ln -sfn "$src" "$dst"
  echo "  Linked: $dst"
}

link_dir_if_exists() {
  local src="$1"
  local dst="$2"
  if [ -d "$src" ]; then
    link "$src" "$dst"
  fi
}

link_file_if_exists() {
  local src="$1"
  local dst="$2"
  local message="$3"
  if [ -f "$src" ]; then
    link "$src" "$dst"
  elif [ -n "$message" ]; then
    echo "  Skipped: $message"
  fi
}

# 공통
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"
link "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"
link_file_if_exists "$DOTFILES/git/.config/git/ignore" "$HOME/.config/git/ignore" \
  "git/ignore not found (create $DOTFILES/git/.config/git/ignore to enable)"
link "$DOTFILES/starship/.config/starship-tty.toml" "$HOME/.config/starship-tty.toml"

link_hyprland() {
  if [ -d "$DOTFILES/hyprland/.config/hypr" ]; then
    link "$DOTFILES/hyprland/.config/hypr" "$HOME/.config/hypr"
  fi
}

case "$OS" in
  macos)
    link_dir_if_exists "$DOTFILES/ghostty/.config/ghostty" "$HOME/.config/ghostty"
    link_dir_if_exists "$DOTFILES/zellij" "$HOME/.config/zellij"
    ;;
  arch)
    link_hyprland
    link_dir_if_exists "$DOTFILES/waybar/.config/waybar" "$HOME/.config/waybar"
    ;;
  cachyos)
    link_hyprland
    link_dir_if_exists "$DOTFILES/quickshell/.config/quickshell" "$HOME/.config/quickshell"
    ;;
esac

echo ""
echo "Done! dotfiles linked for: $OS"

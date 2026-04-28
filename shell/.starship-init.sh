# Shared Starship setup for bash and zsh.
if command -v starship >/dev/null 2>&1; then
  if [ "${TERM_PROGRAM:-}" = "Apple_Terminal" ]; then
    export STARSHIP_CONFIG="$HOME/.config/starship-tty.toml"
  elif [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ] && [ "${TERM:-}" = "linux" ]; then
    export STARSHIP_CONFIG="$HOME/.config/starship-tty.toml"
  else
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
  fi
fi

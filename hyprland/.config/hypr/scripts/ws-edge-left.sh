#!/usr/bin/env bash

# Switch from workspace 2 to 1 when the pointer hits the far-left edge.
trap 'exit 0' TERM INT HUP

cooldown=0

while true; do
  ws_line="$(hyprctl activeworkspace 2>/dev/null || true)"
  ws_id="$(printf '%s\n' "$ws_line" | sed -n 's/^workspace ID \([0-9]\+\).*/\1/p')"

  if [ "$ws_id" = "2" ]; then
    pos="$(hyprctl cursorpos 2>/dev/null || true)"
    x_raw="${pos%%,*}"
    x="${x_raw%%.*}"
    x="${x//[^0-9-]/}"

    if [ -n "$x" ] && [ "$x" -le 1 ] && [ "$cooldown" -eq 0 ]; then
      hyprctl dispatch workspace 1 >/dev/null 2>&1 || true
      cooldown=1
    elif [ -n "$x" ] && [ "$x" -gt 20 ]; then
      cooldown=0
    fi
  else
    cooldown=0
  fi

  sleep 0.08
done

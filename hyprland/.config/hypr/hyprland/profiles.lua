local M = {}
local home = os.getenv("HOME") or "~"

local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return ""
  end

  local contents = file:read("*a") or ""
  file:close()
  return contents
end

local function detect_os_id()
  local os_release = read_file("/etc/os-release"):lower()
  local id = os_release:match('\nid="?([^"\n]+)"?') or os_release:match('^id="?([^"\n]+)"?')
  local id_like = os_release:match('\nid_like="?([^"\n]+)"?') or os_release:match('^id_like="?([^"\n]+)"?') or ""

  if id == "cachyos" or id_like:find("cachyos", 1, true) then
    return "cachyos"
  end

  return "arch"
end

local layout_profile = {
  columns_layout = "dwindle",
  cycle = { "dwindle", "master", "scrolling" },
  names = {
    dwindle = "Dwindle",
    master = "Large main",
    scrolling = "Scrolling",
  },
}

local profiles = {
  arch = {
    file_manager = "env EDITOR=nvim VISUAL=nvim footclient -a yazi -T yazi yazi",
    terminal = "footclient",
    launcher = "fuzzel",
    browser = "firefox",
    monitor_rules = {
      { name = "", resolution = "preferred", position = "auto", scale = "auto" },
    },
    env = {},
    autostart = {
      "foot --server",
      "waybar",
      "dunst",
      "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
      "fcitx5 -d",
      "bash ~/.config/hypr/scripts/battery-suspend-10",
    },
    hypridle_config = [[
general {
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 60
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action battery-dim-display
    on-resume = bash ~/.config/hypr/scripts/idle-power-action battery-restore-display
}

listener {
    timeout = 150
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action battery-kbd-off
    on-resume = bash ~/.config/hypr/scripts/idle-power-action battery-kbd-restore
}

listener {
    timeout = 180
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action ac-dim-display
    on-resume = bash ~/.config/hypr/scripts/idle-power-action ac-restore-display
}

listener {
    timeout = 300
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action battery-lock
}

listener {
    timeout = 300
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action ac-kbd-off
    on-resume = bash ~/.config/hypr/scripts/idle-power-action ac-kbd-restore
}

listener {
    timeout = 480
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action battery-dpms-off
    on-resume = bash ~/.config/hypr/scripts/idle-power-action dpms-on
}

listener {
    timeout = 600
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action battery-shutdown
}

listener {
    timeout = 600
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action ac-lock
}

listener {
    timeout = 900
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action ac-dpms-off
    on-resume = bash ~/.config/hypr/scripts/idle-power-action dpms-on
}

listener {
    timeout = 1800
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action ac-shutdown
}
]],
    appearance = {
      rounding = 4,
      shadow_enabled = false,
      blur_enabled = false,
      animations_enabled = false,
      animations = {
        { leaf = "global", enabled = false, speed = 1, bezier = "default" },
        { leaf = "border", enabled = false, speed = 1, bezier = "default" },
        { leaf = "windows", enabled = false, speed = 1, bezier = "default" },
        { leaf = "windowsIn", enabled = false, speed = 1, bezier = "default" },
        { leaf = "windowsOut", enabled = false, speed = 1, bezier = "default" },
        { leaf = "fadeIn", enabled = false, speed = 1, bezier = "default" },
        { leaf = "fadeOut", enabled = false, speed = 1, bezier = "default" },
        { leaf = "fade", enabled = false, speed = 1, bezier = "default" },
        { leaf = "layers", enabled = false, speed = 1, bezier = "default" },
        { leaf = "layersIn", enabled = false, speed = 1, bezier = "default" },
        { leaf = "layersOut", enabled = false, speed = 1, bezier = "default" },
        { leaf = "fadeLayersIn", enabled = false, speed = 1, bezier = "default" },
        { leaf = "fadeLayersOut", enabled = false, speed = 1, bezier = "default" },
        { leaf = "workspaces", enabled = false, speed = 1, bezier = "default" },
        { leaf = "workspacesIn", enabled = false, speed = 1, bezier = "default" },
        { leaf = "workspacesOut", enabled = false, speed = 1, bezier = "default" },
        { leaf = "zoomFactor", enabled = false, speed = 1, bezier = "default" },
      },
    },
    input = {
      follow_mouse = 0,
      sensitivity = 0,
      touchpad = {
        tap_to_click = true,
        tap_and_drag = true,
        natural_scroll = true,
        disable_while_typing = true,
      },
    },
    binds = {
      "SUPER, T, exec, $terminal",
      "SUPER, W, exec, firefox --private-window",
      "SUPER, backslash, layoutmsg, togglesplit",
      ", XF86LaunchA, exec, fuzzel",
      ", XF86LaunchB, togglespecialworkspace, magic",
      "SUPER SHIFT, ESCAPE, exec, hyprctl dispatch exit",
      "CTRL SUPER, L, exec, hyprctl dispatch dpms off",
      "CTRL SUPER, O, exec, hyprctl dispatch dpms on",
      "CTRL SUPER ALT, R, exec, hyprctl reload",
      "SUPER SHIFT, S, movetoworkspace, special:magic",
    },
    bindl = {
      "CTRL SUPER, SPACE, exec, playerctl play-pause",
      ", switch:on:Lid Switch, exec, " .. home .. "/.local/bin/lid-screen-policy close",
      ", switch:off:Lid Switch, exec, " .. home .. "/.local/bin/lid-screen-policy open",
      ", XF86AudioNext, exec, playerctl next",
      ", XF86AudioPause, exec, playerctl play-pause",
      ", XF86AudioPlay, exec, playerctl play-pause",
      ", XF86AudioPrev, exec, playerctl previous",
    },
    bindel = {
      ",XF86AudioRaiseVolume, exec, ~/.config/hypr/scripts/volume-notify up",
      ",XF86AudioLowerVolume, exec, ~/.config/hypr/scripts/volume-notify down",
      ",XF86AudioMute, exec, ~/.config/hypr/scripts/volume-notify mute",
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
      ",XF86MonBrightnessUp, exec, ~/.config/hypr/scripts/backlight-notify mon_up",
      ",XF86MonBrightnessDown, exec, ~/.config/hypr/scripts/backlight-notify mon_down",
      ",XF86KbdBrightnessUp, exec, ~/.config/hypr/scripts/backlight-notify kbd_up",
      ",XF86KbdBrightnessDown, exec, ~/.config/hypr/scripts/backlight-notify kbd_down",
    },
    window_rules = {
      {
        name = "float-time-control-popup",
        match = { class = "time-control-popup" },
        float = true,
        center = true,
        size = { x = 900, y = 560 },
      },
      {
        name = "float-wifi-connect-popup",
        match = { class = "wifi-connect-popup" },
        float = true,
        center = true,
        size = { x = 980, y = 420 },
      },
      {
        name = "float-yazi",
        match = { class = "^yazi$" },
        float = true,
        center = true,
        size = { x = 1100, y = 720 },
      },
    },
    hyprctl = "hyprctl",
    jq = "jq",
  },
  cachyos = {
    file_manager = "yazi",
    terminal = "footclient",
    launcher = "fuzzel",
    browser = "firefox",
    monitor_rules = {
      { name = "HDMI-A-2", resolution = "1920x1080", position = "0x0", scale = "1" },
      { name = "DP-2", resolution = "1920x1080", position = "1920x0", scale = "1" },
    },
    env = {
      XMODIFIERS = "@im=fcitx",
      GTK_IM_MODULE = "fcitx",
      QT_IM_MODULE = "fcitx",
      SDL_IM_MODULE = "fcitx",
      GLFW_IM_MODULE = "ibus",
      LIBVA_DRIVER_NAME = "nvidia",
      XDG_SESSION_TYPE = "wayland",
      GBM_BACKEND = "nvidia-drm",
      __GLX_VENDOR_LIBRARY_NAME = "nvidia",
    },
    autostart = {
      "foot --server",
      "systemctl --user start pipewire wireplumber pipewire-pulse",
      "systemctl --user start at-spi-dbus-bus",
      "systemctl --user start xdg-desktop-portal",
      "pkill -f ws-edge-left.sh; ~/.config/hypr/scripts/ws-edge-left.sh",
      "quickshell --path ~/.config/quickshell/shell.qml",
      "fcitx5 -d",
    },
    hypridle_config = [[
general {
    lock_cmd = pidof hyprlock || hyprlock --config ~/.config/hypr/hyprlock/hyprlock.conf
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 60
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action dim-display
    on-resume = bash ~/.config/hypr/scripts/idle-power-action restore-display
}

listener {
    timeout = 120
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action lock
}

listener {
    timeout = 330
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action dpms-off
    on-resume = bash ~/.config/hypr/scripts/idle-power-action dpms-on
}

listener {
    timeout = 600
    on-timeout = bash ~/.config/hypr/scripts/idle-power-action suspend-unless-ssh
}
]],
    appearance = {
      rounding = 10,
      shadow_enabled = true,
      blur_enabled = true,
      animations_enabled = true,
      animations = {
        { leaf = "global", enabled = true, speed = 10, bezier = "default" },
        { leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" },
        { leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" },
        { leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" },
        { leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" },
        { leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" },
        { leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" },
        { leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" },
        { leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" },
        { leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" },
        { leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" },
        { leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" },
        { leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" },
        { leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" },
        { leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" },
        { leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" },
        { leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" },
      },
    },
    input = {
      repeat_rate = 30,
      repeat_delay = 350,
      follow_mouse = 0,
      sensitivity = -0.5,
      touchpad = {
        tap_to_click = true,
        tap_and_drag = true,
        natural_scroll = false,
        disable_while_typing = true,
      },
    },
    binds = {
      "SUPER, B, exec, $browser",
      "SUPER SHIFT, Escape, exit,",
      "SUPER, TAB, exec, quickshell ipc call overview toggle",
      "SUPER, J, layoutmsg, togglesplit",
      "SUPER CONTROL, left, workspace, e-1",
      "SUPER CONTROL, right, workspace, e+1",
      "SUPER SHIFT, S, movetoworkspacesilent, special:magic",
      "SUPER ALT, B, exec, hyprctl dispatch alterzorder bottom",
    },
    bindl = {
      ", XF86AudioNext, exec, playerctl next",
      ", XF86AudioPause, exec, playerctl play-pause",
      ", XF86AudioPlay, exec, playerctl play-pause",
      ", XF86AudioPrev, exec, playerctl previous",
    },
    bindel = {
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+",
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-",
    },
    window_rules = {},
    hyprctl = "hyprctl",
    jq = "jq",
  },
}

function M.setup(ctx)
  local os_id = detect_os_id()
  local profile = profiles[os_id] or profiles.arch

  ctx.os_id = os_id
  ctx.os_profile = profile
  ctx.layout_profile = layout_profile
  ctx.terminal = profile.terminal or ctx.terminal
  ctx.file_manager = profile.file_manager or ctx.file_manager
  ctx.browser = profile.browser or ctx.browser
  ctx.menu = profile.launcher or ctx.menu
  ctx.hyprctl_command = profile.hyprctl or "hyprctl"
  ctx.jq_command = profile.jq or "jq"

  ctx.columns_layout = layout_profile.columns_layout or ctx.columns_layout
  ctx.current_layout = ctx.columns_layout
  ctx.layout_cycle = layout_profile.cycle or { ctx.columns_layout, ctx.large_main_layout }
  for layout, name in pairs(layout_profile.names or {}) do
    ctx.layout_names[layout] = name
  end
end

return M

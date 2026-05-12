local shell_ui_command = "hypr_shell_ui"
local power_menu = "bash ~/.config/hypr/scripts/power-menu"
local columns_layout = "nStack"
local large_main_layout = "master"
local grid_layout = "grid"
local monocle_layout = "monocle"
local home = os.getenv("HOME") or "~"

return {
  main_mod = "SUPER",
  mod_alt = "SUPER + ALT",
  hyper = "SUPER + CTRL + ALT",

  terminal = "ghostty --gtk-single-instance=false",
  file_manager = "yazi",
  browser = "firefox",
  menu = "fuzzel",
  shell_ui_command = shell_ui_command,
  launcher_command = "fuzzel",
  power_menu = power_menu,

  notification_icons = {
    warning = 0,
    info = 1,
    hint = 2,
    error = 3,
    confused = 4,
    ok = 5,
    none = 6,
  },

  max_workspace = 9,
  scratchpad_size_ratio = 0.95,
  dropdown_height_ratio = 0.5,
  columns_layout = columns_layout,
  large_main_layout = large_main_layout,
  grid_layout = grid_layout,
  monocle_layout = monocle_layout,
  layout_cycle = { columns_layout, large_main_layout, grid_layout },
  layout_names = {
    [columns_layout] = "Columns",
    [large_main_layout] = "Large main",
    [grid_layout] = "Grid",
    [monocle_layout] = "Monocle",
  },
  minimized_workspace = "special:minimized",
  tabbed_group_restore_workspace_prefix = "special:tabbed-monocle-restore-",
  current_layout = columns_layout,
  enable_nstack = false,
  hyprctl_command = "hyprctl",
  jq_command = "jq",
  configure_nstack_plugin_from_lua = false,
  workspace_layouts = {},
  minimized_windows = {},
  tabbed_workspace_groups = {},
  window_picker_mode = nil,
  window_picker_candidates = {},
  stack_update_timer = nil,
  monocle_notice = nil,
  scratchpad_pending = {},
  monitor_reserved_cache_path = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hyprland-monitor-reserved.tsv",
  scratchpad_fallback_reserved_top = 60,

  scratchpads = {
    codex = {
      command = "codex-desktop",
      class = "codex-desktop",
    },
    htop = {
      command = "alacritty --class htop-scratch --title htop -e htop",
      class = "htop-scratch",
    },
    volume = {
      command = "pavucontrol",
      class = "org.pulseaudio.pavucontrol",
    },
    spotify = {
      command = "spotify",
      class = "spotify",
    },
    element = {
      command = "element-desktop",
      classes = { "Element", "electron" },
      title = "Element",
    },
    slack = {
      command = "slack",
      class = "Slack",
    },
    messages = {
      command = "google-chrome-stable --profile-directory=Default --app=https://messages.google.com/web/conversations",
      class = "chrome-messages.google.com",
    },
    transmission = {
      command = "transmission-gtk",
      class = "transmission-gtk",
    },
    dropdown = {
      command = "ghostty --config-file=" .. home .. "/.config/ghostty/dropdown",
      class = "com.mitchellh.ghostty.dropdown",
      dropdown = true,
    },
  },
}

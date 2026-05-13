local M = {}

function M.setup(ctx)
  local _ENV = ctx
  local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
  end

  local function write_profile_hypridle_config()
    local config = os_profile and os_profile.hypridle_config
    if not config or config == "" then
      return nil
    end

    local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
    local config_home = runtime_dir .. "/hypridle-" .. tostring(os_id or "default")
    local config_dir = config_home .. "/hypr"
    local path = config_dir .. "/hypridle.conf"
    os.execute("mkdir -p " .. shell_quote(config_dir))

    local file = io.open(path, "w")
    if not file then
      return nil
    end

    file:write(config)
    if config:sub(-1) ~= "\n" then
      file:write("\n")
    end
    file:close()
    return config_home
  end

  local function start_profile_hypridle()
    if verify_config then
      return
    end

    local config_home = write_profile_hypridle_config()
    if config_home then
      hl.exec_cmd("pkill hypridle; env XDG_CONFIG_HOME=" .. shell_quote(config_home) .. " hypridle")
    end
  end

  local function run_profile_autostart()
    if verify_config then
      return
    end

    for _, command in ipairs((os_profile and os_profile.autostart) or {}) do
      hl.exec_cmd(command)
    end
  end

  hl.on("hyprland.start", function()
    apply_nstack_config()
    apply_rules()
    start_profile_hypridle()
    run_profile_autostart()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    write_layout_state()
    schedule_nstack_count_update()
    refresh_monitor_reserved_cache(0.25)
    refresh_monitor_reserved_cache(1.25)
  end)

  hl.on("config.reloaded", apply_nstack_config)
  hl.on("config.reloaded", apply_profile_monitors)
  hl.on("config.reloaded", apply_rules)
  hl.on("config.reloaded", refresh_shell_workarea_and_scratchpads)
  hl.on("layer.opened", refresh_shell_workarea_and_scratchpads)
  hl.on("layer.closed", refresh_shell_workarea_and_scratchpads)
  hl.on("monitor.added", refresh_shell_workarea_and_scratchpads)
  hl.on("monitor.removed", refresh_shell_workarea_and_scratchpads)
  hl.on("monitor.layout_changed", refresh_shell_workarea_and_scratchpads)

  hl.on("window.open", schedule_nstack_count_update)
  hl.on("window.destroy", schedule_nstack_count_update)
  hl.on("window.kill", schedule_nstack_count_update)
  hl.on("window.move_to_workspace", schedule_nstack_count_update)
  hl.on("workspace.active", sync_layout_for_active_workspace)
  hl.on("monitor.focused", sync_layout_for_active_workspace)

  hl.on("window.open", update_monocle_notice)
  hl.on("window.destroy", update_monocle_notice)
  hl.on("window.kill", update_monocle_notice)
  hl.on("window.move_to_workspace", update_monocle_notice)

  hl.on("window.open", adopt_matching_scratchpad_window)
  hl.on("window.class", adopt_matching_scratchpad_window)
  hl.on("window.title", adopt_matching_scratchpad_window)
end

return M

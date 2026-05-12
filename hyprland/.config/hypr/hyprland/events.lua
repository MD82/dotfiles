local M = {}

function M.setup(ctx)
  local _ENV = ctx
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

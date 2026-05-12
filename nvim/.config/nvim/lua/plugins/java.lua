local root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", ".git" }

local function collect_java_bundles()
  local mason_path = vim.fn.stdpath("data") .. "/mason"
  local bundles = {}

  local java_debug = vim.fn.glob(
    mason_path .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true,
    true
  )
  vim.list_extend(bundles, java_debug)

  local java_test = vim.fn.glob(mason_path .. "/packages/java-test/extension/server/*.jar", true, true)
  vim.list_extend(bundles, java_test)

  return bundles
end

local function jdtls_cmd()
  local mason_path = vim.fn.stdpath("data") .. "/mason"
  local jdtls_bin = mason_path .. "/bin/jdtls"

  if vim.fn.executable(jdtls_bin) == 1 then
    return { jdtls_bin }
  end

  local package_path = mason_path .. "/packages/jdtls"
  local launcher = vim.fn.glob(package_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher == "" then
    return { "jdtls" }
  end

  local config_dir
  if vim.fn.has("mac") == 1 then
    config_dir = package_path .. "/config_mac"
  elseif vim.fn.has("win32") == 1 then
    config_dir = package_path .. "/config_win"
  else
    config_dir = package_path .. "/config_linux"
  end

  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
  local cmd = { "java", "-Xmx2g", "-Xms512m" }
  local lombok_path = package_path .. "/lombok.jar"

  if vim.fn.filereadable(lombok_path) == 1 then
    table.insert(cmd, "-javaagent:" .. lombok_path)
  end

  vim.list_extend(cmd, {
    "-jar",
    launcher,
    "-configuration",
    config_dir,
    "-data",
    workspace_dir,
  })

  return cmd
end

local function project_command(root_dir, profile)
  local gradlew = root_dir .. "/gradlew"
  local mvnw = root_dir .. "/mvnw"

  if vim.fn.executable(gradlew) == 1 then
    local command = "./gradlew bootRun"
    if profile and profile ~= "" then
      command = command .. " --args='--spring.profiles.active=" .. profile .. "'"
    end
    return command
  end

  if vim.fn.executable(mvnw) == 1 then
    local command = "./mvnw spring-boot:run"
    if profile and profile ~= "" then
      command = command .. " -Dspring-boot.run.profiles=" .. profile
    end
    return command
  end
end

local function project_debug_command(root_dir, profile)
  local gradlew = root_dir .. "/gradlew"
  local mvnw = root_dir .. "/mvnw"

  if vim.fn.executable(gradlew) == 1 then
    local command = "./gradlew bootRun --debug-jvm"
    if profile and profile ~= "" then
      command = command .. " --args='--spring.profiles.active=" .. profile .. "'"
    end
    return command
  end

  if vim.fn.executable(mvnw) == 1 then
    local command = "./mvnw spring-boot:run -Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005'"
    if profile and profile ~= "" then
      command = command .. " -Dspring-boot.run.profiles=" .. profile
    end
    return command
  end
end

local function run_terminal(command, cwd)
  vim.cmd("botright " .. math.floor(vim.o.lines * 0.35) .. "split")
  vim.fn.termopen(command, { cwd = cwd })
  vim.cmd("startinsert")
end

local function java_root(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.fs.root(name, root_markers)
end

local function setup_java_dap()
  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if ok_jdtls then
    pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
    pcall(require("jdtls.dap").setup_dap_main_class_configs)
  end

  local ok_dap, dap = pcall(require, "dap")
  if not ok_dap then
    return
  end

  dap.configurations.java = dap.configurations.java or {}
  local attach_config = {
    type = "java",
    request = "attach",
    name = "Attach Spring Boot :5005",
    hostName = "127.0.0.1",
    port = 5005,
  }

  for _, item in ipairs(dap.configurations.java) do
    if item.name == attach_config.name then
      return
    end
  end
  table.insert(dap.configurations.java, attach_config)
end

local function jdtls_action(action)
  return function()
    local ok, jdtls = pcall(require, "jdtls")
    if ok and jdtls[action] then
      jdtls[action]()
    else
      vim.notify("nvim-jdtls action is unavailable: " .. action, vim.log.levels.WARN, { title = "jdtls" })
    end
  end
end

vim.lsp.config("jdtls", {
  cmd = jdtls_cmd(),
  filetypes = { "java" },
  root_markers = root_markers,
  init_options = {
    bundles = collect_java_bundles(),
  },
  settings = {
    java = {
      format = { enabled = true },
      saveActions = { organizeImports = true },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
        },
      },
      sources = { organizeImports = { starThreshold = 9999 } },
    },
  },
})
vim.lsp.enable("jdtls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data and ev.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end

    setup_java_dap()

    local root_dir = client.config.root_dir or java_root(ev.buf)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
    end

    map("<leader>jo", jdtls_action("organize_imports"), "Organize imports")
    map("<leader>jv", jdtls_action("extract_variable"), "Extract variable")
    map("<leader>jm", jdtls_action("extract_method"), "Extract method")
    map("<leader>jt", jdtls_action("test_nearest_method"), "Test method")
    map("<leader>jT", jdtls_action("test_class"), "Test class")
    map("<leader>jb", jdtls_action("build_projects"), "Build project")
    map("<leader>js", function()
      local command = root_dir and project_command(root_dir)
      if not command then
        vim.notify("No gradlew or mvnw found", vim.log.levels.WARN, { title = "Spring Boot" })
        return
      end
      run_terminal(command, root_dir)
    end, "Spring Boot run")
    map("<leader>jS", function()
      local profile = vim.fn.input("Spring profile: ")
      local command = root_dir and project_command(root_dir, profile)
      if not command then
        vim.notify("No gradlew or mvnw found", vim.log.levels.WARN, { title = "Spring Boot" })
        return
      end
      run_terminal(command, root_dir)
    end, "Spring Boot run with profile")
    map("<leader>jD", function()
      local profile = vim.fn.input("Spring profile: ")
      local command = root_dir and project_debug_command(root_dir, profile)
      if not command then
        vim.notify("No gradlew or mvnw found", vim.log.levels.WARN, { title = "Spring Boot" })
        return
      end
      run_terminal(command, root_dir)
    end, "Spring Boot debug run :5005")
    map("<leader>ja", function()
      local ok, dap = pcall(require, "dap")
      if not ok then
        vim.notify("nvim-dap is unavailable", vim.log.levels.WARN, { title = "Spring Boot" })
        return
      end
      dap.run({
        type = "java",
        request = "attach",
        name = "Attach Spring Boot :5005",
        hostName = "127.0.0.1",
        port = 5005,
      })
    end, "Attach Spring Boot debugger")
  end,
})

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "mfussenegger/nvim-dap" },
  },
}

local root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", ".git" }

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

local function run_terminal(command, cwd)
  vim.cmd("botright " .. math.floor(vim.o.lines * 0.35) .. "split")
  vim.fn.termopen(command, { cwd = cwd })
  vim.cmd("startinsert")
end

local function java_root(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.fs.root(name, root_markers)
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
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_markers = root_markers,
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

    local root_dir = client.config.root_dir or java_root(ev.buf)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
    end

    map("<leader>jo", jdtls_action("organize_imports"), "Organize imports")
    map("<leader>jv", jdtls_action("extract_variable"), "Extract variable")
    map("<leader>jm", jdtls_action("extract_method"), "Extract method")
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
  end,
})

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },
}

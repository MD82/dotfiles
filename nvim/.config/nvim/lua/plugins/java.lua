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

vim.lsp.config("jdtls", {
  cmd = jdtls_cmd(),
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", ".git" },
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

return {}

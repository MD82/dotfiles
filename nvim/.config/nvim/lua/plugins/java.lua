return {
  -- Java LSP (jdtls)
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "mason-org/mason.nvim" },
    ft = "java",  -- Java 파일 열 때만 로드
    config = function()
      local unpack_fn = table.unpack or unpack
      local mason_path = vim.fn.stdpath("data") .. "/mason"
      local jdtls_path = mason_path .. "/packages/jdtls"

      local function collect_java_bundles()
        local bundles = {}

        local java_debug = vim.fn.glob(
          mason_path .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
          true,
          true
        )
        vim.list_extend(bundles, java_debug)

        local java_test = vim.fn.glob(
          mason_path .. "/packages/java-test/extension/server/*.jar",
          true,
          true
        )
        vim.list_extend(bundles, java_test)

        return bundles
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

        return nil
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

        return nil
      end

      local function run_terminal(command, cwd)
        vim.cmd("botright " .. math.floor(vim.o.lines * 0.35) .. "split")
        vim.fn.termopen(command, { cwd = cwd })
        vim.cmd("startinsert")
      end

      -- OS별 설정 파일
      local config_dir
      if vim.fn.has("mac") == 1 then
        config_dir = jdtls_path .. "/config_mac"
      elseif vim.fn.has("win32") == 1 then
        config_dir = jdtls_path .. "/config_win"
      else
        config_dir = jdtls_path .. "/config_linux"
      end

      -- 프로젝트별 workspace 분리
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

      -- lombok 경로 (있을 경우)
      local lombok_path = mason_path .. "/packages/jdtls/lombok.jar"
      local jvm_args = { "-Xmx2g", "-Xms512m" }
      if vim.fn.filereadable(lombok_path) == 1 then
        table.insert(jvm_args, "-javaagent:" .. lombok_path)
      end

      local root_dir = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" })
      if not root_dir then
        vim.notify("No Java project root found", vim.log.levels.WARN, { title = "jdtls" })
        return
      end

      local config = {
        cmd = {
          "java",
          unpack_fn(jvm_args),
          "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration", config_dir,
          "-data", workspace_dir,
        },
        root_dir = root_dir,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
          java = {
            format = { enabled = true },
            saveActions = { organizeImports = true },
            completion = { favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
            }},
            sources = { organizeImports = { starThreshold = 9999 } },
          },
        },
        init_options = {
          bundles = collect_java_bundles(),
        },
      }

      require("jdtls").start_or_attach(config)
      pcall(require("jdtls").setup_dap, { hotcodereplace = "auto" })
      pcall(require("jdtls.dap").setup_dap_main_class_configs)

      local dap = require("dap")
      dap.configurations.java = dap.configurations.java or {}
      local attach_config = {
        type = "java",
        request = "attach",
        name = "Attach Spring Boot :5005",
        hostName = "127.0.0.1",
        port = 5005,
      }
      local has_attach_config = false
      for _, item in ipairs(dap.configurations.java) do
        if item.name == attach_config.name then
          has_attach_config = true
          break
        end
      end
      if not has_attach_config then
        table.insert(dap.configurations.java, attach_config)
      end

      -- Java 전용 단축키
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data and ev.data.client_id)
          if not client or client.name ~= "jdtls" then return end
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
          end
          map("<leader>jo", "<cmd>lua require('jdtls').organize_imports()<cr>",        "Organize imports")
          map("<leader>jv", "<cmd>lua require('jdtls').extract_variable()<cr>",        "Extract variable")
          map("<leader>jm", "<cmd>lua require('jdtls').extract_method()<cr>",          "Extract method")
          map("<leader>jt", "<cmd>lua require('jdtls').test_nearest_method()<cr>",     "Test method")
          map("<leader>jT", "<cmd>lua require('jdtls').test_class()<cr>",              "Test class")
          map("<leader>jb", "<cmd>lua require('jdtls').build_projects()<cr>",          "Build project")
          map("<leader>js", function()
            local command = project_command(root_dir)
            if not command then
              vim.notify("No gradlew or mvnw found", vim.log.levels.WARN, { title = "Spring Boot" })
              return
            end
            run_terminal(command, root_dir)
          end, "Spring Boot run")
          map("<leader>jS", function()
            local profile = vim.fn.input("Spring profile: ")
            local command = project_command(root_dir, profile)
            if not command then
              vim.notify("No gradlew or mvnw found", vim.log.levels.WARN, { title = "Spring Boot" })
              return
            end
            run_terminal(command, root_dir)
          end, "Spring Boot run with profile")
          map("<leader>jD", function()
            local profile = vim.fn.input("Spring profile: ")
            local command = project_debug_command(root_dir, profile)
            if not command then
              vim.notify("No gradlew or mvnw found", vim.log.levels.WARN, { title = "Spring Boot" })
              return
            end
            run_terminal(command, root_dir)
          end, "Spring Boot debug run :5005")
          map("<leader>ja", function()
            require("dap").run({
              type = "java",
              request = "attach",
              name = "Attach Spring Boot :5005",
              hostName = "127.0.0.1",
              port = 5005,
            })
          end, "Attach Spring Boot debugger")
        end,
      })
    end,
  },
}

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

      local config = {
        cmd = {
          "java",
          unpack_fn(jvm_args),
          "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration", config_dir,
          "-data", workspace_dir,
        },
        root_dir = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" }),
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
          bundles = {},  -- java-debug, vscode-java-test 번들 추가 가능
        },
      }

      require("jdtls").start_or_attach(config)

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
        end,
      })
    end,
  },
}

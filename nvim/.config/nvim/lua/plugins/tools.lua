return {
  -- 파일 트리
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File tree" },
    },
    config = function()
      require("nvim-tree").setup({
        git = {
          ignore = false,
        },
      })
    end,
  },

  -- 퍼지 검색
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Find Files (Fuzzy)",
            results_title = "Path / File Name",
          })
        end,
        desc = "Find files (fuzzy)",
      },
      {
        "<leader>fp",
        function()
          local text = vim.fn.input("Path contains: ")
          if text == "" then
            return
          end

          require("telescope.builtin").find_files({
            prompt_title = "Find Files (Path Contains)",
            results_title = "Contains: " .. text,
            default_text = text,
            find_command = {
              "sh",
              "-c",
              string.format("rg --files | rg -F --smart-case -- %s", vim.fn.shellescape(text)),
            },
          })
        end,
        desc = "Path contains",
      },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent files" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          path_display = {
            filename_first = {
              reverse_directories = true,
            },
          },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopePrompt",
        callback = function()
          vim.opt_local.iminsert = 0
          vim.opt_local.imsearch = 0
        end,
      })
    end,
  },

  -- 문법 하이라이팅
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function()
      vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
      require("nvim-treesitter").setup({
        ensure_installed = { "java", "lua", "xml", "json", "yaml", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git
  { "lewis6991/gitsigns.nvim", config = true },
  { "tpope/vim-fugitive" },

  -- 괄호 자동 닫기
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  -- 주석 토글 (gcc / gc)
  { "numToStr/Comment.nvim", config = true },

  -- 터미널 토글
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>t", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal" },
    },
    config = function()
      require("toggleterm").setup()

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
        noremap = true,
        silent = true,
        desc = "Exit terminal mode",
      })
    end,
  },
}

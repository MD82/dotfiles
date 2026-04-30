return {
  -- 테마
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    cond = function()
      return vim.loop.os_uname().sysname == "Darwin"
    end,
    opts = {
      style = "night",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    cond = function()
      return vim.loop.os_uname().sysname ~= "Darwin"
    end,
    config = function()
      require("solarized").setup({ theme = "neo" })
      vim.o.background = "light"
      vim.cmd.colorscheme("solarized")
    end,
  },

  -- 상태바
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "echasnovski/mini.icons" },
    config = function()
      local function file_label()
        if vim.bo.buftype == "terminal" then return "Terminal" end

        local name = vim.fn.expand("%:t")
        return name ~= "" and name or "[No Name]"
      end

      require("lualine").setup({
        options = {
          theme = vim.loop.os_uname().sysname == "Darwin" and "tokyonight" or "solarized_light",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { file_label },
          lualine_x = {
            "encoding",
            { "fileformat", symbols = { unix = "unix", dos = "dos", mac = "mac" } },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- 단축키 힌트
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.add({
        { "<leader>w", desc = "Save" },
        { "<leader>q", desc = "Quit" },
        { "<leader>e", desc = "Root explorer" },
        { "<leader>E", desc = "File explorer" },
        { "<leader>t", desc = "Terminal" },
        { "<leader>f",  desc = "Format" },
        { "<leader>ff", desc = "Find files" },
        { "<leader>fg", desc = "Live grep" },
        { "<leader>fb", desc = "Buffers" },
        { "<leader>fr", desc = "Recent files" },
      })
    end,
  },
}

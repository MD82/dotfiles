return {
  -- 테마
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized").setup({ theme = "neo" })
      vim.o.background = "light"
      vim.cmd.colorscheme("solarized")
    end,
  },

  -- 상태바
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function file_label()
        if vim.bo.filetype == "toggleterm" then
          local term_id = vim.b.toggle_number or string.match(vim.api.nvim_buf_get_name(0), "#toggleterm#(%d+)")
          return term_id and ("Terminal " .. term_id) or "Terminal"
        end

        local name = vim.fn.expand("%:t")
        return name ~= "" and name or "[No Name]"
      end

      require("lualine").setup({
        options = {
          theme = "solarized_light",
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
        { "<leader>x",  group = "Diagnostics" },
        { "<leader>xx", desc = "Diagnostics toggle" },
      })
    end,
  },

  -- 에러/경고 목록
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
    },
    config = true,
  },
}

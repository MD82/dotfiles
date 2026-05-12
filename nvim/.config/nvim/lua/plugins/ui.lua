return {
  -- 테마
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light"
      vim.g.everforest_better_performance = 1
      vim.cmd.colorscheme("everforest")
      vim.api.nvim_set_hl(0, "Comment", { fg = "#7a8478", italic = true })
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
          theme = "everforest",
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
        { "<leader>e", group = "Explorer" },
        { "<leader>ef", desc = "File explorer" },
        { "<leader>ew", desc = "Workspace explorer" },
        { "<leader>eg", desc = "File explorer (hide .gitignore)" },
        { "<leader>t", group = "Terminal" },
        { "<leader>th", desc = "Terminal horizontal" },
        { "<leader>tv", desc = "Terminal vertical" },
        { "<leader>tf", desc = "Terminal float" },
        { "<leader>tq", desc = "Terminal quit" },
        { "<leader>f",  desc = "Format" },
        { "<leader>ff", desc = "Find files" },
        { "<leader>fg", desc = "Live grep" },
        { "<leader>fb", desc = "Buffers" },
        { "<leader>fr", desc = "Recent files" },
        { "<leader>g", group = "Git" },
        { "<leader>gd", desc = "Git diff" },
        { "<leader>gs", desc = "Git status" },
        { "<leader>gc", desc = "Git commit" },
        { "<leader>h", group = "Git hunk" },
        { "<leader>hs", desc = "Hunk stage" },
        { "<leader>hr", desc = "Hunk reset" },
        { "<leader>hp", desc = "Hunk preview" },
        { "<leader>hb", desc = "현재 줄 blame 토글" },
        { "g", group = "이동/정보" },
        { "gg", desc = "파일 처음으로 이동" },
        { "gd", desc = "정의로 이동" },
        { "gI", desc = "구현으로 이동" },
        { "gr", desc = "참조 찾기" },
        { "gf", desc = "커서 아래 파일 열기" },
        { "gF", desc = "커서 아래 파일/줄 열기" },
        { "gi", desc = "마지막 입력 위치로 이동" },
        { "gv", desc = "마지막 선택 영역 다시 선택" },
        { "gc", group = "주석" },
        { "gcc", desc = "현재 줄 주석 토글" },
        { "z", group = "접기/화면" },
        { "za", desc = "접기 토글" },
        { "zo", desc = "접기 열기" },
        { "zc", desc = "접기 닫기" },
        { "zR", desc = "모든 접기 열기" },
        { "zM", desc = "모든 접기 닫기" },
        { "zz", desc = "현재 줄 중앙 정렬" },
        { "zt", desc = "현재 줄 위쪽 정렬" },
        { "zb", desc = "현재 줄 아래쪽 정렬" },
      })
    end,
  },
}

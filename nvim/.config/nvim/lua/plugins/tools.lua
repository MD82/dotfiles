local function build_find_command()
  return { "rg", "--files", "--glob", "!.git/*", "--glob", "!node_modules/**" }
end

local function list_project_files(cwd)
  if vim.fn.executable("rg") == 1 then
    local result = vim.system(build_find_command(), { cwd = cwd, text = true }):wait()
    if result.code == 0 and result.stdout then
      return vim.split(vim.trim(result.stdout), "\n", { plain = true, trimempty = true })
    end
  end

  local files = {}
  for path, entry_type in vim.fs.dir(cwd, { depth = math.huge }) do
    if entry_type == "file" and not path:match("^%.git/") and not path:match("^node_modules/") then
      table.insert(files, path)
    end
  end
  return files
end

return {
  -- 아이콘
  {
    "echasnovski/mini.icons",
    version = false,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- 파일 트리
  {
    "echasnovski/mini.files",
    version = false,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Root explorer",
      },
      {
        "<leader>E",
        function()
          local buf_type = vim.bo.buftype
          local buf_name = vim.api.nvim_buf_get_name(0)
          local path = vim.uv.cwd()

          if buf_type == "" and buf_name ~= "" then
            local full_path = vim.fn.fnamemodify(buf_name, ":p")
            local fs_type = vim.uv.fs_stat(full_path and full_path ~= "" and full_path or "")
            if fs_type then
              path = fs_type.type == "directory" and full_path or full_path
            end
          end

          require("mini.files").open(path, true)
        end,
        desc = "File explorer",
      },
    },
    config = function()
      local mini_files = require("mini.files")
      local marker_ns = vim.api.nvim_create_namespace("mini_files_focus_marker")

      local function refresh_mini_files_focus_marker()
        local ok, mf = pcall(require, "mini.files")
        if not ok then return end

        local ok_state, state = pcall(mf.get_explorer_state)
        if not ok_state or not state then return end

        local current_win = vim.api.nvim_get_current_win()
        local current_index = nil
        for index, win in ipairs(state.windows) do
          if win.win_id == current_win then
            current_index = index
            break
          end
        end

        if not current_index then
          current_index = math.min(state.depth_focus, #state.windows)
          current_win = state.windows[current_index] and state.windows[current_index].win_id or nil
        end

        for _, win in ipairs(state.windows) do
          if vim.api.nvim_win_is_valid(win.win_id) then
            local buf_id = vim.api.nvim_win_get_buf(win.win_id)
            vim.api.nvim_buf_clear_namespace(buf_id, marker_ns, 0, -1)
            vim.wo[win.win_id].signcolumn = win.win_id == current_win and "yes:1" or "no"
          end
        end

        if not (current_win and vim.api.nvim_win_is_valid(current_win)) then return end

        local buf_id = vim.api.nvim_win_get_buf(current_win)
        local line = vim.api.nvim_win_get_cursor(current_win)[1] - 1

        vim.api.nvim_buf_set_extmark(buf_id, marker_ns, line, 0, {
          sign_text = ">",
          sign_hl_group = "MiniFilesTitleFocused",
        })
      end

      local function pick_files_from_mini_files()
        local state = mini_files.get_explorer_state()
        if not state then return end

        local current_win = vim.api.nvim_get_current_win()
        local current_path = nil

        for _, win in ipairs(state.windows) do
          if win.win_id == current_win then
            current_path = win.path
            break
          end
        end

        if not current_path then
          local focused = state.windows[math.min(state.depth_focus, #state.windows)]
          current_path = focused and focused.path or vim.uv.cwd()
        end

        local stat = current_path and vim.uv.fs_stat(current_path) or nil
        local search_dir = (stat and stat.type == "directory") and current_path or vim.fn.fnamemodify(current_path, ":h")
        local target_win = state.target_window

        mini_files.close()
        if target_win and vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_set_current_win(target_win)
        end

        vim.schedule(function()
          require("mini.pick").builtin.files({ tool = "rg" }, { source = { cwd = search_dir } })
        end)
      end

      local function set_cwd_from_mini_files()
        local state = mini_files.get_explorer_state()
        if not state then return end

        local current_win = vim.api.nvim_get_current_win()
        local current_path = nil

        for _, win in ipairs(state.windows) do
          if win.win_id == current_win then
            current_path = win.path
            break
          end
        end

        if not current_path then
          local focused = state.windows[math.min(state.depth_focus, #state.windows)]
          current_path = focused and focused.path or vim.uv.cwd()
        end

        local entry = mini_files.get_fs_entry()
        if entry and entry.path then
          current_path = entry.path
        end

        local stat = current_path and vim.uv.fs_stat(current_path) or nil
        local new_cwd = (stat and stat.type == "directory") and current_path or vim.fn.fnamemodify(current_path, ":h")

        vim.api.nvim_set_current_dir(new_cwd)
        mini_files.close()
        if state.target_window and vim.api.nvim_win_is_valid(state.target_window) then
          vim.api.nvim_set_current_win(state.target_window)
        end
        vim.notify("cwd -> " .. new_cwd, vim.log.levels.INFO, { title = "mini.files" })
      end

      vim.api.nvim_set_hl(0, "MiniFilesTitle", { fg = "#f9e2af", bold = true })
      vim.api.nvim_set_hl(0, "MiniFilesTitleFocused", { link = "FloatTitle" })

      vim.api.nvim_create_autocmd("User", {
        pattern = { "MiniFilesExplorerOpen", "MiniFilesWindowUpdate" },
        callback = function(args)
          if args.match == "MiniFilesExplorerOpen" then
            mini_files.set_bookmark("h", "~", { desc = "Home" })
          end
          refresh_mini_files_focus_marker()
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          if not (args.data and args.data.buf_id) then return end

          vim.keymap.set("n", "<leader>ff", pick_files_from_mini_files, {
            buffer = args.data.buf_id,
            desc = "Find files from current mini.files directory",
          })
          vim.keymap.set("n", "ff", pick_files_from_mini_files, {
            buffer = args.data.buf_id,
            desc = "Find files from current mini.files directory",
          })
          vim.keymap.set("n", "@", set_cwd_from_mini_files, {
            buffer = args.data.buf_id,
            remap = false,
            silent = true,
            desc = "Set cwd from current mini.files directory",
          })
        end,
      })

      mini_files.setup({
        options = {
          use_as_default_explorer = false,
          permanent_delete = false,
        },
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 40,
        },
        mappings = {
          close = "<Esc>",
          go_in = "l",
          go_in_plus = "<CR>",
          go_out = "H",
          go_out_plus = "h",
          mark_goto = "'",
          mark_set = "m",
          reset = "<BS>",
          reveal_cwd = "",
          show_help = "g?",
          synchronize = "=",
          trim_left = "<",
          trim_right = ">",
        },
      })
    end,
  },

  -- 퍼지 검색
  {
    "echasnovski/mini.pick",
    version = false,
    keys = {
      {
        "<leader>ff",
        function()
          require("mini.pick").builtin.files({ tool = "rg" })
        end,
        desc = "Find files (fuzzy)",
      },
      {
        "<leader>fp",
        function()
          local pick = require("mini.pick")
          local text = vim.fn.input("Path contains: ")
          if text == "" then return end

          pick.start({
            source = {
              name = "Contains: " .. text,
              cwd = vim.uv.cwd(),
              items = function()
                local items = {}
                for _, path in ipairs(list_project_files(vim.uv.cwd())) do
                  if path:find(text, 1, true) then table.insert(items, path) end
                end
                return items
              end,
              show = pick.default_show,
            },
          })
        end,
        desc = "Path contains",
      },
      {
        "<leader>fg",
        function()
          require("mini.pick").builtin.grep_live()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          require("mini.pick").builtin.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fr",
        function()
          require("mini.extra").pickers.oldfiles()
        end,
        desc = "Recent files",
      },
    },
    config = function()
      require("mini.pick").setup({
        window = {
          config = function()
            local height = math.floor(vim.o.lines * 0.5)
            local width = math.floor(vim.o.columns * 0.8)
            return {
              anchor = "NW",
              height = height,
              width = width,
              row = math.floor((vim.o.lines - height) / 2),
              col = math.floor((vim.o.columns - width) / 2),
            }
          end,
        },
      })
    end,
  },

  -- mini.pick oldfiles 지원
  {
    "echasnovski/mini.extra",
    version = false,
    opts = {},
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
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "┆" },
          delete       = { text = "▁" },
          topdelete    = { text = "▔" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r)
            vim.keymap.set(mode, l, r, { buffer = bufnr })
          end

          map("n", "]c", gs.next_hunk)
          map("n", "[c", gs.prev_hunk)
          map("n", "<leader>hs", gs.stage_hunk)
          map("n", "<leader>hr", gs.reset_hunk)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", gs.toggle_current_line_blame)
        end,
      })
    end,
  },
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",        desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git commit" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Git diff split" },
    },
  },

  -- 괄호 자동 닫기
  {
    "echasnovski/mini.pairs",
    version = false,
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = false, terminal = false },
      mappings = {
        ["'"] = false,
        ['"'] = false,
        ["`"] = false,
      },
    },
  },

  -- 주석 토글 (gcc / gc)
  {
    "echasnovski/mini.comment",
    version = false,
    opts = {},
  },

  -- 들여쓰기 범위 시각화
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "BufReadPre",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
  },

}

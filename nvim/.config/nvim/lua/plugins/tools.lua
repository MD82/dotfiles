local exclude_globs = {
  "!node_modules/**",
  "!dist/**",
  "!build/**",
  "!target/**",
  "!coverage/**",
  "!.cache/**",
  "!*.jpg",
  "!*.jpeg",
  "!*.png",
  "!*.gif",
  "!*.webp",
  "!*.pdf",
  "!*.lock",
  "!*.woff",
  "!*.woff2",
  "!*.otf",
  "!*.eot",
}

local function build_find_command()
  return { "rg", "--files", "--glob", "!.git/*", "--glob", "!node_modules/**" }
end

return {
  -- 파일 트리
  {
    "echasnovski/mini.files",
    version = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
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

      local function set_winhl(win_id, from, to)
        local entry = from .. ":" .. to
        local pattern = string.format("(%s:[^,]*)", vim.pesc(from))
        local winhl = vim.wo[win_id].winhighlight or ""
        local new_winhl, replaced = winhl:gsub(pattern, entry)
        if replaced == 0 then
          new_winhl = (new_winhl == "" and entry) or (new_winhl .. "," .. entry)
        end
        vim.wo[win_id].winhighlight = new_winhl
      end

      local function refresh_mini_files_focus_marker()
        local ok, mini_files = pcall(require, "mini.files")
        if not ok then
          return
        end

        local ok_state, state = pcall(mini_files.get_explorer_state)
        if not ok_state or not state then
          return
        end

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

        local parent_win = current_index and state.windows[current_index - 1] and state.windows[current_index - 1].win_id or nil

        for _, win in ipairs(state.windows) do
          if vim.api.nvim_win_is_valid(win.win_id) then
            local buf_id = vim.api.nvim_win_get_buf(win.win_id)
            vim.api.nvim_buf_clear_namespace(buf_id, marker_ns, 0, -1)
            vim.wo[win.win_id].signcolumn = win.win_id == current_win and "yes:1" or "no"
            set_winhl(win.win_id, "FloatBorder", win.win_id == parent_win and "MiniFilesBorderParent" or "MiniFilesBorder")
            set_winhl(win.win_id, "FloatTitle", win.win_id == parent_win and "MiniFilesTitleParent" or "MiniFilesTitle")
          end
        end

        if not (current_win and vim.api.nvim_win_is_valid(current_win)) then
          return
        end

        local buf_id = vim.api.nvim_win_get_buf(current_win)
        local line = vim.api.nvim_win_get_cursor(current_win)[1] - 1

        vim.api.nvim_buf_set_extmark(buf_id, marker_ns, line, 0, {
          sign_text = ">",
          sign_hl_group = "MiniFilesTitleFocused",
        })

      end

      local function telescope_find_files_from_mini_files()
        local state = mini_files.get_explorer_state()
        if not state then
          return
        end

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
          require("telescope.builtin").find_files({
            cwd = search_dir,
            prompt_title = "Find Files (Mini Files Dir)",
            results_title = search_dir,
          })
        end)
      end

      local function set_cwd_from_mini_files()
        local state = mini_files.get_explorer_state()
        if not state then
          return
        end

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

      vim.api.nvim_set_hl(0, "MiniFilesTitleFocused", {
        fg = "#f9e2af",
        bold = true,
      })
      vim.api.nvim_set_hl(0, "MiniFilesBorderParent", {
        fg = "#74c7ec",
        bg = "#1e1e2e",
      })
      vim.api.nvim_set_hl(0, "MiniFilesTitleParent", {
        fg = "#1e1e2e",
        bg = "#74c7ec",
        bold = true,
      })

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
          if not (args.data and args.data.buf_id) then
            return
          end

          vim.keymap.set("n", "<leader>ff", telescope_find_files_from_mini_files, {
            buffer = args.data.buf_id,
            desc = "Find files from current mini.files directory",
          })
          vim.keymap.set("n", "ff", telescope_find_files_from_mini_files, {
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
            find_command = build_find_command(),
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
          layout_strategy = "flex",
          layout_config = {
            flex = {
              flip_columns = 120,
            },
            horizontal = {
              preview_width = 0.55,
            },
            vertical = {
              preview_height = 0.45,
            },
            width = 0.95,
            height = 0.9,
          },
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
  {
    "lewis6991/gitsigns.nvim",
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

          -- 이동
          map("n", "]c", gs.next_hunk)
          map("n", "[c", gs.prev_hunk)

          -- 핵심 기능
          map("n", "<leader>hs", gs.stage_hunk)
          map("n", "<leader>hr", gs.reset_hunk)
          map("n", "<leader>hp", gs.preview_hunk)

          -- 블레임
          map("n", "<leader>hb", gs.toggle_current_line_blame)
        end,
      })
    end,
  },
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",         desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<CR>",  desc = "Git commit" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>",  desc = "Git diff split" },
    },
  },

  -- 괄호 자동 닫기
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({})
      -- 따옴표/백틱 자동 닫기 비활성화
      autopairs.remove_rule("`")
      autopairs.remove_rule("'")
      autopairs.remove_rule('"')
    end,
  },

  -- 주석 토글 (gcc / gc)
  { "numToStr/Comment.nvim", config = true },

  -- 터미널 토글
  {
    "akinsho/toggleterm.nvim",
    keys = {
      {
        "<leader>t",
        function()
          require("toggleterm").toggle(1, nil, nil, "horizontal")
        end,
        desc = "Terminal",
      },
    },
    config = function()
      local toggleterm = require("toggleterm")

      toggleterm.setup({
        direction = "horizontal",
      })

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
        noremap = true,
        silent = true,
        desc = "Exit terminal mode",
      })
    end,
  },
}

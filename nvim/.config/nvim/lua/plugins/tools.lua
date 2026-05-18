local function build_find_command()
  return { "rg", "--files", "--glob", "!.git/*", "--glob", "!node_modules/**" }
end

local cwd_changed = false
local gitignore_filter_cache = {}
local project_roots = {
  { name = "dotfiles", path = "~/.dotfiles" },
  { name = "projects", path = "~/gitRepository_wsl" },
  { name = "healthcareSite", path = "~/gitRepository_wsl/ConnectJ/healthcareSite" },
  { name = "healthcareAdmin", path = "~/gitRepository_wsl/ConnectJ/healthcareAdmin" },
  { name = "home", path = "~" },
}

local function git_root_for(path)
  local dir = path
  local stat = dir and vim.uv.fs_stat(dir) or nil
  if stat and stat.type ~= "directory" then
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return dir and vim.fs.root(dir, ".git") or nil
end

local function is_gitignored(path)
  local root = git_root_for(path)
  if not root then return false end

  gitignore_filter_cache[root] = gitignore_filter_cache[root] or {}
  local cache = gitignore_filter_cache[root]
  if cache[path] ~= nil then return cache[path] end

  local rel = vim.fn.fnamemodify(path, ":p"):sub(#vim.fn.fnamemodify(root, ":p") + 1)
  local result = vim.system({ "git", "-C", root, "check-ignore", "--quiet", "--", rel }):wait()
  cache[path] = result.code == 0
  return cache[path]
end

local function mini_files_filter_gitignore(fs_entry)
  return not is_gitignored(fs_entry.path)
end

local function current_file_explorer_path()
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

  return path
end

local function open_workspace_explorer(opts)
  local mf = require("mini.files")
  local restore = not cwd_changed
  cwd_changed = false
  mf.open(vim.uv.cwd(), restore, opts)
end

local function open_file_explorer(opts)
  require("mini.files").open(current_file_explorer_path(), true, opts)
end

local function open_gitignore_filtered_file_explorer()
  open_file_explorer({ content = { filter = mini_files_filter_gitignore } })
end

local function choose_mini_files_explorer()
  local choices = {
    { label = "Workspace explorer", action = open_workspace_explorer },
    { label = "File explorer", action = open_file_explorer },
    { label = "File explorer (hide .gitignore)", action = open_gitignore_filtered_file_explorer },
  }

  vim.ui.select(choices, {
    prompt = "Mini.files:",
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice then choice.action() end
  end)
end

local function available_project_roots()
  local roots = {}
  for _, project in ipairs(project_roots) do
    local path = vim.fn.fnamemodify(vim.fn.expand(project.path), ":p")
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == "directory" then
      table.insert(roots, { name = project.name, path = path })
    end
  end
  return roots
end

local function switch_project()
  local projects = available_project_roots()
  if #projects == 0 then
    vim.notify("No configured project directories found", vim.log.levels.WARN, { title = "Project" })
    return
  end

  vim.ui.select(projects, {
    prompt = "Project:",
    format_item = function(item) return item.name .. "  " .. item.path end,
  }, function(choice)
    if not choice then return end

    vim.cmd("silent tcd " .. vim.fn.fnameescape(choice.path))
    cwd_changed = true
    require("mini.files").open(choice.path, false)
  end)
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
        "<C-e>",
        choose_mini_files_explorer,
        desc = "Choose explorer",
      },
      {
        "<leader>pp",
        switch_project,
        desc = "Switch project",
      },
    },
    config = function()
      local mini_files = require("mini.files")
      local marker_ns = vim.api.nvim_create_namespace("mini_files_focus_marker")
      local last_target_window = nil

      local function is_regular_edit_window(win_id)
        if not (win_id and vim.api.nvim_win_is_valid(win_id)) then return false end
        if vim.api.nvim_win_get_config(win_id).relative ~= "" then return false end

        local buf_id = vim.api.nvim_win_get_buf(win_id)
        return vim.bo[buf_id].buftype == ""
      end

      local function remember_target_window()
        local win_id = vim.api.nvim_get_current_win()
        if is_regular_edit_window(win_id) then
          last_target_window = win_id
        end
      end

      local function get_target_window(preferred)
        if is_regular_edit_window(preferred) then return preferred end
        if is_regular_edit_window(last_target_window) then return last_target_window end

        for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if is_regular_edit_window(win_id) then return win_id end
        end
      end

      local function fix_mini_files_target_window()
        local state = mini_files.get_explorer_state()
        if not state then return end

        local target_window = get_target_window(state.target_window)
        if target_window then
          mini_files.set_target_window(target_window)
        end
      end

      local function close_lazy_windows()
        for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(win_id) then
            local buf_id = vim.api.nvim_win_get_buf(win_id)
            if vim.bo[buf_id].filetype == "lazy" then
              vim.api.nvim_win_close(win_id, true)
            end
          end
        end
      end

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
        local target_win = get_target_window(state.target_window)

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

        local new_cwd = current_path

        vim.api.nvim_set_current_dir(new_cwd)
        cwd_changed = true
        mini_files.close()
        local target_win = get_target_window(state.target_window)
        if target_win then
          vim.api.nvim_set_current_win(target_win)
        end
        vim.notify("cwd -> " .. new_cwd, vim.log.levels.INFO, { title = "mini.files" })
      end

      local function get_current_fs_entry()
        local ok, entry = pcall(mini_files.get_fs_entry)
        return ok and entry or nil
      end

      local function open_entry_from_mini_files()
        local entry = get_current_fs_entry()
        if not entry then return end

        if entry and entry.fs_type == "directory" then
          set_cwd_from_mini_files()
        else
          close_lazy_windows()
          fix_mini_files_target_window()
          mini_files.go_in({ close_on_file = true })
        end
      end

      local function enter_directory_from_mini_files()
        local entry = get_current_fs_entry()
        if entry and entry.fs_type == "directory" then
          mini_files.go_in()
        end
      end

      vim.api.nvim_set_hl(0, "MiniFilesTitle", { fg = "#f9e2af", bold = true })
      vim.api.nvim_set_hl(0, "MiniFilesTitleFocused", { link = "FloatTitle" })

      vim.api.nvim_create_autocmd("User", {
        pattern = { "MiniFilesExplorerOpen", "MiniFilesWindowUpdate" },
        callback = function(args)
          if args.match == "MiniFilesExplorerOpen" then
            mini_files.set_bookmark("h", "~", { desc = "Home" })
            fix_mini_files_target_window()
          end
          refresh_mini_files_focus_marker()
        end,
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        callback = remember_target_window,
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
          vim.keymap.set("n", "<CR>", open_entry_from_mini_files, {
            buffer = args.data.buf_id,
            remap = false,
            silent = true,
            desc = "Open file or set cwd for directory",
          })
          vim.keymap.set("n", "l", enter_directory_from_mini_files, {
            buffer = args.data.buf_id,
            remap = false,
            silent = true,
            desc = "Enter directory",
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
          go_in = "",
          go_in_plus = "",
          go_out = "H",
          go_out_plus = "h",
          mark_goto = "'",
          mark_set = "m",
          reset = "<BS>",
          reveal_cwd = "",
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
    lazy = true,
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
    event = "BufReadPost",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "┆" },
          delete       = { text = "▁" },
          topdelete    = { text = "▔" },
          changedelete = { text = "~" },
        },
        current_line_blame = false,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          local function open_git_diff()
            local source_win = vim.api.nvim_get_current_win()
            local opened_wins = {}
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              opened_wins[win] = true
            end

            gs.diffthis(nil, { vertical = true, split = "rightbelow" }, function()
              vim.schedule(function()
                if not vim.api.nvim_win_is_valid(source_win) then return end

                local tabpage = vim.api.nvim_win_get_tabpage(source_win)
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
                  if not opened_wins[win] and vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_set_current_win(win)
                    return
                  end
                end
              end)
            end)
          end

          map("n", "]c", gs.next_hunk, "다음 Git 변경으로 이동")
          map("n", "[c", gs.prev_hunk, "이전 Git 변경으로 이동")
          map("n", "<leader>ghs", gs.stage_hunk, "Hunk stage")
          map("n", "<leader>ghr", gs.reset_hunk, "Hunk reset")
          map("n", "<leader>ghp", gs.preview_hunk, "Hunk preview")
          map("n", "<leader>ghb", gs.toggle_current_line_blame, "현재 줄 blame 토글")
          map("n", "<leader>gd", open_git_diff, "Git diff")
          map("n", "<leader>gs", function() vim.cmd("botright 12split | terminal git status") end, "Git status")
          map("n", "<leader>gc", function() vim.cmd("botright 12split | terminal git commit") end, "Git commit")
        end,
      })
    end,
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

  -- 확장 textobject (argument/function/tag 등)
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    opts = {},
  },

  -- 들여쓰기 범위 시각화
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "BufReadPost",
    init = function()
      local excluded_filetypes = {
        dashboard = true,
        gitcommit = true,
        help = true,
        lazy = true,
        markdown = true,
        mason = true,
        terminal = true,
      }

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if excluded_filetypes[vim.bo.filetype] then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
  },

}

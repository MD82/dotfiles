local opt = vim.opt

-- 줄 번호
opt.number = true
opt.relativenumber = true

-- 들여쓰기
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- 검색
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:block,o:block"

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Cursor", { fg = "#1e1e2e", bg = "#a6e3a1" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "#1e1e2e", bg = "#a6e3a1" })
  end,
})

-- 파일
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.undofile = true

-- 분할 방향
opt.splitright = true
opt.splitbelow = true

-- 업데이트 속도 (LSP 반응속도)
opt.updatetime = 250

-- 외부에서 파일 수정 시 버퍼 자동 갱신
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

local function open_markdown_preview(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  if vim.fn.executable("glow") ~= 1 then
    vim.notify("glow executable not found", vim.log.levels.WARN, { title = "markdown preview" })
    return
  end

  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" or vim.bo[buf].buftype ~= "" then return end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end

    local preview_width = 80

    if vim.o.columns >= 120 then
      vim.cmd("botright vertical " .. preview_width .. "split")
      vim.cmd("enew")
    else
      local width = math.floor(vim.o.columns * 0.9)
      local height = math.floor(vim.o.lines * 0.8)

      vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
      })
    end

    vim.fn.termopen({ "glow", "-p", path })
    vim.bo.buflisted = false
    vim.cmd("startinsert")
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = true,
      silent = true,
      desc = "Close markdown preview",
    })
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>mp", function()
      open_markdown_preview(args.buf)
    end, {
      buffer = args.buf,
      silent = true,
      desc = "Open markdown preview",
    })
  end,
})

-- 상태줄
opt.statusline = "%f %m%r%h%w%=%{&fileencoding}  %y  %l:%c"

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

-- 상태줄
opt.statusline = "%f %m%r%h%w%=%{&fileencoding}  %y  %l:%c"

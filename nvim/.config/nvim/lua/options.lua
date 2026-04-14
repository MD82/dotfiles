local opt = vim.opt

function _G.input_mode_label()
  return vim.o.iminsert == 1 and "KO" or "EN"
end

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

-- 파일
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.undofile = true

-- 분할 방향
opt.splitright = true
opt.splitbelow = true

-- 업데이트 속도 (LSP 반응속도)
opt.updatetime = 250

-- AI 에이전트가 파일 수정 시 버퍼 자동 갱신 (nic 워크플로우)
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- 상태줄에 입력 모드 표시
opt.statusline = "%f %m%r%h%w%=%{v:lua.input_mode_label()}  %y  %l:%c"

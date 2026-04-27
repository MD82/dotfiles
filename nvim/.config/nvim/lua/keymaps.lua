local map = vim.keymap.set

-- 저장 / 종료
map("n", "<leader>w", "<cmd>w<cr>",  { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>",  { desc = "Quit" })

-- 창 이동 (Ctrl + hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Move left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move up" })
map("n", "<C-l>", "<C-w>l", { desc = "Move right" })

-- 버퍼 이동
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })

-- 들여쓰기 유지
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 줄 이동 (Alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==",  { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",  { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",  { desc = "Move line down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",  { desc = "Move line up" })

-- ESC 대체
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })

-- 터미널 모드에서 편집창으로 이동
map("t", "<C-w>k", [[<C-\><C-n><C-w>k]], { desc = "Terminal → upper window" })

-- 터미널 토글 (내장)
local term_buf = nil
map("n", "<leader>t", function()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local win = vim.fn.bufwinid(term_buf)
    if win ~= -1 then
      vim.api.nvim_win_hide(win)
      return
    end
  end
  vim.cmd("botright " .. math.floor(vim.o.lines * 0.3) .. "split")
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_win_set_buf(0, term_buf)
  else
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd("startinsert")
end, { desc = "Terminal toggle" })

map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })

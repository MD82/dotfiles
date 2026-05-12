local map = vim.keymap.set

-- 저장 / 종료
map("n", "<leader>w", "<cmd>w<cr>",  { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>",  { desc = "Quit" })

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

-- 터미널 토글 (내장)
local term_buf = nil
local term_win = nil

local function terminal_size()
  return {
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
  }
end

local function open_terminal_window(layout)
  if layout == "float" then
    local size = terminal_size()
    local buf = term_buf and vim.api.nvim_buf_is_valid(term_buf) and term_buf or vim.api.nvim_create_buf(false, true)

    term_win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = size.width,
      height = size.height,
      row = math.floor((vim.o.lines - size.height) / 2),
      col = math.floor((vim.o.columns - size.width) / 2),
      border = "rounded",
      style = "minimal",
    })
    return
  end

  if layout == "vertical" then
    vim.cmd("botright " .. math.floor(vim.o.columns * 0.35) .. "vsplit")
  else
    vim.cmd("botright " .. math.floor(vim.o.lines * 0.3) .. "split")
  end

  term_win = vim.api.nvim_get_current_win()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_win_set_buf(term_win, term_buf)
  end
end

local function toggle_terminal(layout)
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local win = vim.fn.bufwinid(term_buf)
    if win ~= -1 then
      vim.api.nvim_win_hide(win)
      term_win = nil
      return
    end
  end

  open_terminal_window(layout)
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd("startinsert")
end

local function close_terminal()
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    term_buf = nil
    term_win = nil
    return
  end

  local job_id = vim.b[term_buf].terminal_job_id
  if job_id then
    pcall(vim.fn.jobstop, job_id)
  end

  pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
  term_buf = nil
  term_win = nil
end

map("n", "<leader>th", function() toggle_terminal("horizontal") end, { desc = "Terminal horizontal" })
map("n", "<leader>tv", function() toggle_terminal("vertical") end, { desc = "Terminal vertical" })
map("n", "<leader>tf", function() toggle_terminal("float") end, { desc = "Terminal float" })
map("n", "<leader>tq", close_terminal, { desc = "Terminal quit" })

map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })

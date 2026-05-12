local function executable(path)
  return vim.fn.executable(path) == 1
end

local function mason_bin(name)
  return vim.fn.stdpath("data") .. "/mason/bin/" .. name
end

vim.o.autocomplete = false
vim.o.complete = ".,w,b,u,t"
vim.o.completeopt = "menu,popup,noselect"
vim.o.pumheight = 7

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data and ev.data.client_id)
    if not client then
      return
    end

    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })

    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = desc })
    end

    map("i", "<C-Space>", function()
      vim.lsp.completion.get()
    end, "Trigger LSP completion")

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "<leader>ci", vim.lsp.buf.incoming_calls, "Incoming calls")
    map("n", "<leader>co", vim.lsp.buf.outgoing_calls, "Outgoing calls")
    map("n", "K", vim.lsp.buf.hover, "Hover docs")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, "LSP Format")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

local lua_ls = mason_bin("lua-language-server")
vim.lsp.config("lua_ls", {
  cmd = { executable(lua_ls) and lua_ls or "lua-language-server" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable("lua_ls")

return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua-language-server",
        "jdtls",
        "java-debug-adapter",
        "java-test",
      },
    },
  },
}

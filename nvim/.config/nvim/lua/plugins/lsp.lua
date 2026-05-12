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
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    map("i", "<C-f>", "<C-x><C-f>", "Path completion")

    if client:supports_method("textDocument/signatureHelp") and not vim.b[ev.buf].lsp_signature_autocmd then
      vim.b[ev.buf].lsp_signature_autocmd = true
      vim.api.nvim_create_autocmd("InsertCharPre", {
        buffer = ev.buf,
        callback = function()
          if vim.v.char == "(" or vim.v.char == "," then
            vim.schedule(function()
              vim.lsp.buf.signature_help()
            end)
          end
        end,
      })
    end

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

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable("lua_ls")

return {}

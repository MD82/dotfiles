return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: toggle breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug: continue",
      },
      {
        "<leader>dn",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: step over",
      },
      {
        "<F8>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: step over",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: step into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: step out",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug: open REPL",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Debug: run last",
      },
      {
        "<leader>dx",
        function()
          require("dap").disconnect({ terminateDebuggee = false })
        end,
        desc = "Debug: disconnect",
      },
      {
        "<leader>dX",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: terminate",
      },
    },
    config = function()
      local dap = require("dap")

      -- Java needs java-debug bundles before attach/launch configurations work.
      dap.configurations.java = dap.configurations.java or {}
    end,
  },
}

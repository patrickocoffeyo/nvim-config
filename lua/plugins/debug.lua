return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "leoluz/nvim-dap-go",
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    "theHamsta/nvim-dap-virtual-text",
  },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Debug: start or continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Debug: start or continue" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Debug: conditional breakpoint",
    },
    { "<leader>dt", function() require("dap-go").debug_test() end, desc = "Debug: nearest Go test" },
    { "<leader>dT", function() require("dap-go").debug_last_test() end, desc = "Debug: last Go test" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
    {
      "<leader>dx",
      function()
        require("dap").terminate()
      end,
      desc = "Debug: terminate session",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Register Delve as the Go debug adapter and add Go launch/test configurations.
    require("dap-go").setup({
      tests = {
        verbose = true,
      },
    })

    -- Keep debugger state visible without permanently claiming editor space.
    dapui.setup({
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.45 },
            { id = "breakpoints", size = 0.15 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.15 },
          },
          position = "right",
          size = 42,
        },
        {
          elements = { "repl", "console" },
          position = "bottom",
          size = 12,
        },
      },
    })

    -- Show evaluated values beside Go variables whenever execution pauses.
    require("nvim-dap-virtual-text").setup({
      commented = true,
    })

    -- Open the debugger panes only for an active launch or attach session.
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end

    -- Close the temporary debugger layout once Delve ends the session.
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}

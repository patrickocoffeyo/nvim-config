return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
    {
      "fredrikaverpil/neotest-golang",
      version = "*",
      -- Install gotestsum for neotest-golang's preferred runner.
      build = function()
        vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
      end,
    },
  },

  -- Configure Neotest for manual runs; save-triggered package tests are handled
  -- by config.go-test so they stay scoped to the current package.
  config = function()
    local go_test = require("config.go-test")
    local config = {
      runner = "gotestsum",
      go_test_args = go_test.coverage_args,
      warn_test_name_dupes = false,
    }
    local neotest = require("neotest")
    neotest.setup({
      adapters = {
        require("neotest-golang")(config),
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neotest-output",
      -- Make Neotest's output pane dismissible with the same keys as other panes.
      callback = function(args)
        -- Close whichever output window is currently active.
        local function close_output_window()
          local win = vim.api.nvim_get_current_win()

          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end

        local opts = { buffer = args.buf, nowait = true, silent = true, desc = "Close test output" }
        vim.keymap.set({ "n", "t" }, "q", close_output_window, opts)
        vim.keymap.set({ "n", "t" }, "<Esc>", close_output_window, opts)
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.go",
      -- Re-run only the saved file's package so unrelated duplicate test names
      -- elsewhere in the repo do not pollute the feedback loop.
      callback = function(args)
        go_test.run_package(args.buf)
      end,
    })
  end,
}

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
      build = function()
        vim.system({"go", "install", "gotest.tools/gotestsum@latest"}):wait()
      end,
    },
  },

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
      callback = function(args)
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
      callback = function(args)
        go_test.run_package(args.buf)
      end,
    })
  end,
}

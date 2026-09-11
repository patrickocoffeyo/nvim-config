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

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.go",
      callback = function(args)
        go_test.run_package(args.buf)
      end,
    })
  end,
}

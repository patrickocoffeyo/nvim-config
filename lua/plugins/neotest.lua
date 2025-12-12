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
    local config = {
      runner = "gotestsum",
    }
    local neotest = require("neotest")
    neotest.setup({
      adapters = {
        require("neotest-golang")(config),
      },
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.go",
      callback = function()
        local file = vim.fs.normalize(vim.fn.expand("%:p"))
        local dir = vim.fs.dirname(file)
        local coverage_file = dir .. "/coverage.out"

        -- Run tests for this package directory.
        neotest.run.run(dir)

        -- Poll for updated coverage.out.
        local before = vim.loop.fs_stat(coverage_file)
          and vim.loop.fs_stat(coverage_file).mtime.sec

        local timer = vim.loop.new_timer()
        timer:start(250, 250, function()
          local stat = vim.loop.fs_stat(coverage_file)
          if stat and stat.mtime.sec ~= before then
            timer:stop()
            timer:close()

            vim.schedule(function()
              require("coverage").load()
              require("coverage").show()
            end)
          end
        end)
      end,
    })
  end,
}

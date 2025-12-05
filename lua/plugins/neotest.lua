return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-go",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/nvim-nio",
  },

  config = function()
    local neotest = require("neotest")

    neotest.setup({
      adapters = {
        require("neotest-go")({
          recursive_run = true,
          args = {
            "-count=1",
            "-timeout=60s",
            "-coverprofile=coverage.out",
          },
        }),
      },
    })

    -- Run Go tests automatically on file save.
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.go",
      callback = function()
        local neotest = require("neotest")
        local coverage = require("coverage")

        local file = vim.fs.normalize(vim.fn.expand("%:p"))
        local dir  = vim.fs.dirname(file)
        local coverage_file = dir .. "/coverage.out"

        neotest.run.run(dir)

        local before = vim.loop.fs_stat(coverage_file)
          and vim.loop.fs_stat(coverage_file).mtime.sec

        local timer = vim.loop.new_timer()
        timer:start(250, 250, function()
          local stat = vim.loop.fs_stat(coverage_file)
          if stat and stat.mtime.sec ~= before then
            timer:stop()
            timer:close()

            vim.schedule(function()
              if vim.loop.fs_stat(coverage_file) then
                coverage.load({ coverage_file = coverage_file })
                coverage.show()
              else
                print("Coverage file not found at " .. coverage_file)
              end
            end)
          end
        end)
      end,
    })
  end,
}

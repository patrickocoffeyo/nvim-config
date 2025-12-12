return {
  "andythigpen/nvim-coverage",
  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()
    require("coverage").setup({
      auto_reload = true,

      load_coverage_fn = function(lang)
        local file = vim.fn.expand("%:p")
        local dir = vim.fn.fnamemodify(file, ":h")

        -- Per-package Go coverage
        local pkg_cov = dir .. "/coverage.out"
        if vim.loop.fs_stat(pkg_cov) then
          return pkg_cov
        end

        -- Fallback to project root (probably won't be needed)
        local root = vim.fs.root(file, { "go.mod", ".git" })
        if root then
          local root_cov = root .. "/coverage.out"
          if vim.loop.fs_stat(root_cov) then
            return root_cov
          end
        end

        return nil
      end,

      highlights = {
        covered   = { fg = "#00ff00" },
        uncovered = { fg = "#ff0000" },
      },

      signs = {
        covered   = { hl = "CoverageCovered",   text = "▎" },
        uncovered = { hl = "CoverageUncovered", text = "▎" },
      },
    })
  end,
}

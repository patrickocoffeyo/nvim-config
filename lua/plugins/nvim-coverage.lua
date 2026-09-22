return {
  "andythigpen/nvim-coverage",
  dependencies = { "nvim-lua/plenary.nvim" },

  -- Point nvim-coverage at the exact Go coverprofile produced by our test helper.
  config = function()
    -- Prefer the explicit profile set by config.go-test, then fall back to the
    -- current package and project-root coverage.out conventions.
    local function go_coverage_file()
      if vim.g.go_test_coverage_file and vim.uv.fs_stat(vim.g.go_test_coverage_file) then
        return vim.g.go_test_coverage_file
      end

      local file = vim.api.nvim_buf_get_name(0)
      if file == "" then
        return "coverage.out"
      end

      local dir = vim.fs.dirname(vim.fs.normalize(file))
      local pkg_cov = dir .. "/coverage.out"
      if vim.uv.fs_stat(pkg_cov) then
        return pkg_cov
      end

      local root = vim.fs.root(file, { "go.mod", ".git" })
      if root then
        return root .. "/coverage.out"
      end

      return pkg_cov
    end

    require("coverage").setup({
      auto_reload = false,

      lang = {
        go = {
          coverage_file = go_coverage_file,
        },
      },

      highlights = {
        covered = { fg = "#b8bb26" },
        uncovered = { fg = "#fb4934" },
        partial = { fg = "#fabd2f" },
      },

      signs = {
        covered = { hl = "CoverageCovered", text = "▌" },
        uncovered = { hl = "CoverageUncovered", text = "▌" },
        partial = { hl = "CoveragePartial", text = "▌" },
      },
    })
  end,
}

return {
  "romgrk/barbar.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  -- Let the opts table below be the single source of truth for Barbar setup.
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    animation = true,
    clickable = true,
    exclude_ft = { "neo-tree" },
    focus_on_close = "previous",
    highlight_visible = true,
    tabpages = true,
    icons = {
      preset = "slanted",
      button = "×",
      inactive = { button = "×" },
    },
  },
}

-- Enable and configure gruvbox colorscheme.
return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  -- Load gruvbox early and use its dark variant as the base UI palette.
  config = function()
    vim.o.background = "dark"
    require("gruvbox").setup({
      contrast = "hard",
    })
    vim.cmd("colorscheme gruvbox")
  end,
}

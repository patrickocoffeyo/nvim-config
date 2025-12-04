return {
  "nvim-treesitter/nvim-treesitter-context",
  config = function()
    require("treesitter-context").setup({
      enable = true,
      line_numbers = true,
      multiline_threshold = 3,
    })
  end,
}
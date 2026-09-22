return {
  "nvim-treesitter/nvim-treesitter-context",
  -- Show the current syntactic parent near the top of long code windows.
  config = function()
    require("treesitter-context").setup({
      enable = true,
      line_numbers = true,
      multiline_threshold = 3,
    })
  end,
}

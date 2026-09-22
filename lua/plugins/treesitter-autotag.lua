return {
  "windwp/nvim-ts-autotag",
  event = "VeryLazy",
  -- Enable automatic closing/renaming of paired markup tags.
  config = function()
    require("nvim-ts-autotag").setup()
  end,
}

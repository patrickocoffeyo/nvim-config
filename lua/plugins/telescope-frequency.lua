return {
  "nvim-telescope/telescope-frecency.nvim",
  dependencies = { "tami5/sqlite.lua" },
  config = function()
    require("telescope").load_extension("frecency")
  end,
}
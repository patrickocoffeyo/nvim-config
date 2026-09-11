return {
  "nvim-telescope/telescope-frecency.nvim",
  version = "^1.0.0",
  dependencies = { "tami5/sqlite.lua" },
  config = function()
    require("telescope").load_extension("frecency")
  end,
}

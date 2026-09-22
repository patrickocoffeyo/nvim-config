return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  -- Configure the global statusline after startup to keep initial load light.
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        icons_enabled = true,
        globalstatus = true,
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}

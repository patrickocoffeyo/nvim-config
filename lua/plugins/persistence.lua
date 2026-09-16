return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  init = function()
    require("config.session").setup()
  end,
  opts = {
    need = 1,
    branch = false,
  },
  keys = {
    {
      "<leader>ss",
      function()
        require("config.session").load()
      end,
      desc = "Restore session for cwd",
    },
    {
      "<leader>sS",
      function()
        require("config.session").select()
      end,
      desc = "Select session",
    },
    {
      "<leader>sl",
      function()
        require("config.session").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>sd",
      function()
        require("config.session").stop()
      end,
      desc = "Disable session saving",
    },
  },
}

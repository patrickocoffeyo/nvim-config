return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  -- Register session save/load guards before Persistence starts restoring.
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
      -- Restore the session tied to the current working directory.
      function()
        require("config.session").load()
      end,
      desc = "Restore session for cwd",
    },
    {
      "<leader>sS",
      -- Open Persistence's picker when more than one saved session is relevant.
      function()
        require("config.session").select()
      end,
      desc = "Select session",
    },
    {
      "<leader>sl",
      -- Restore the most recently saved session regardless of cwd.
      function()
        require("config.session").load({ last = true })
      end,
      desc = "Restore last session",
    },
    {
      "<leader>sd",
      -- Stop autosave for throwaway edits in this Neovim process.
      function()
        require("config.session").stop()
      end,
      desc = "Disable session saving",
    },
  },
}

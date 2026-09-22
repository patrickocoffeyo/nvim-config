return {
  "linrongbin16/gitlinker.nvim",
  cmd = "GitLink",
  keys = {
    -- Copy a permalink for the current line or selected visual range.
    { "<leader>gy", "<Cmd>GitLink<CR>", mode = { "n", "v" }, desc = "Copy Git link" },
    -- Open that same permalink in the browser instead of copying it.
    { "<leader>gY", "<Cmd>GitLink!<CR>", mode = { "n", "v" }, desc = "Open Git link" },
  },
  opts = {},
}

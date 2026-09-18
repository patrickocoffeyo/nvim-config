return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>mp", "<Cmd>RenderMarkdown buf_toggle<CR>", desc = "Toggle Markdown render" },
    { "<leader>mP", "<Cmd>RenderMarkdown preview<CR>", desc = "Open Markdown preview" },
  },
  opts = {
    file_types = { "markdown" },
    completions = {
      lsp = {
        enabled = true,
      },
    },
  },
}

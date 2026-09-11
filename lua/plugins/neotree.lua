return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = "rounded",

      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
    })

    -- Keymaps.
    vim.keymap.set("n", "<leader>e", ":Neotree toggle left<CR>", { desc = "Toggle file tree" })
    vim.keymap.set("n", "<leader>o", ":Neotree focus left<CR>", { desc = "Focus file tree" })

    -- Auto open neotree on startup.
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Only open if no file was provided
        if vim.fn.argc() == 0 then
          require("neo-tree.command").execute({ action = "show", source = "filesystem", position = "left" })
        end
      end,
    })
  end,
}

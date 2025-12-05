return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.0",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },

  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "%.git/" },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "%.git/" },
      },
      pickers = {
        find_files = {
          hidden = true,
          follow = true,
          file_ignore_patterns = { "%.git/" },
        },
      },
      extensions = {
        fzf = {
          fuzzy = false,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    -- Load fzf extension.
    pcall(telescope.load_extension, "fzf")

    -- Keymaps.
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
  end,
}
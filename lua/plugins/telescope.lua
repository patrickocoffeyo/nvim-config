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

    local function live_grep()
      require("telescope.builtin").live_grep({
        prompt_title = "Search project",
        additional_args = function()
          return { "--hidden", "--glob", "!.git/*" }
        end,
      })
    end

    local function live_grep_everything()
      require("telescope.builtin").live_grep({
        prompt_title = "Search project, including ignored files",
        additional_args = function()
          return { "--hidden", "--no-ignore", "--glob", "!.git/*" }
        end,
      })
    end

    telescope.setup({
      defaults = {
        file_ignore_patterns = { "%.git/" },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
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
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    vim.keymap.set("n", "<leader>fg", live_grep, { desc = "Telescope live grep" })
    vim.keymap.set("n", "<leader>fG", live_grep_everything, { desc = "Telescope live grep including ignored files" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope grep word under cursor" })
    vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume previous search" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
  end,
}

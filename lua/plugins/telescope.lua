return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.4",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },

  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        sorting_strategy = "ascending",

        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--ignore",
        },

        find_command = {
          "rg",
          "--files",
          "--hidden",
          "--ignore",
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

    -- Enable fzf extension.
    pcall(function()
      telescope.load_extension("fzf")
    end)

    -- Keymaps.
    local keymap = vim.keymap.set
    local builtin = require("telescope.builtin")
    local rootFilePatterns = { ".git", "go.mod", "package.json" }

    vim.keymap.set("n", "<leader>ff", function()
      local cwd = vim.fn.getcwd()
      local root = vim.fs.root(cwd, rootFilePatterns)
      builtin.find_files({
        cwd = root or cwd,
      })
    end, { desc = "Find files (cwd)" })

    vim.keymap.set("n", "<leader>fr", function()
      require("telescope").extensions.frecency.frecency({
        workspace = "CWD",
      })
    end, { desc = "Recent Files (Frecency)" })

    keymap("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    keymap("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    keymap("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
  end,
}
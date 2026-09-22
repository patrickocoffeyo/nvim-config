return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  -- Configure Neo-tree as the project drawer and handle directory startup.
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = "rounded",
      nesting_rules = {
        ["go"] = {
          pattern = "(.+)%.go$",
          files = { "%1_test.go", "%1_mock.go" },
        },
        ["typescript"] = {
          pattern = "(.+)%.ts$",
          files = { "%1_test.ts", "%1_mock.ts" },
        },
        ["javascript"] = {
          pattern = "(.+)%.js$",
          files = { "%1_test.js", "%1_mock.js" },
        },
      },

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

    -- Open Neo-tree's filesystem source in the left sidebar.
    local function open_filesystem()
      require("neo-tree.command").execute({ action = "show", source = "filesystem", position = "left" })
    end

    -- Handle `nvim .`/`nvim some-dir` by switching cwd to that directory,
    -- deleting the inert directory buffer, and showing Neo-tree instead.
    local function open_directory_arg()
      if vim.fn.argc() ~= 1 then
        return false
      end

      local path = vim.fn.fnamemodify(vim.fn.argv(0), ":p")
      if vim.fn.isdirectory(path) ~= 1 then
        return false
      end

      local dir_buf = vim.api.nvim_get_current_buf()
      vim.cmd("cd " .. vim.fn.fnameescape(path))
      vim.cmd("enew")

      if vim.api.nvim_buf_is_valid(dir_buf) then
        vim.api.nvim_buf_delete(dir_buf, { force = true })
      end

      open_filesystem()
      return true
    end

    -- Auto open neotree on startup.
    vim.api.nvim_create_autocmd("VimEnter", {
      -- If Neovim starts on a directory, replace that inert buffer with Neo-tree.
      callback = function()
        if open_directory_arg() then
          return
        end

        -- Only open if no file was provided
        if vim.fn.argc() == 0 then
          open_filesystem()
        end
      end,
    })
  end,
}

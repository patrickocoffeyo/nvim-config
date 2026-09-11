return {
  "xTacobaco/cursor-agent.nvim",
  config = function()
    require("cursor-agent").setup({})

    local function close_cursor_agent_window()
      local win = vim.api.nvim_get_current_win()

      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    local function is_cursor_agent_terminal(bufnr)
      local name = vim.api.nvim_buf_get_name(bufnr)

      return vim.bo[bufnr].buftype == "terminal" and name:find("cursor%-agent") ~= nil
    end

    local function set_cursor_agent_close_keymaps(bufnr)
      if not is_cursor_agent_terminal(bufnr) then
        return
      end

      local opts = { buffer = bufnr, nowait = true, silent = true, desc = "Close Cursor Agent" }
      vim.keymap.set("t", "<C-q>", close_cursor_agent_window, opts)
      vim.keymap.set("n", "<C-q>", close_cursor_agent_window, opts)
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(args)
        set_cursor_agent_close_keymaps(args.buf)

        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            set_cursor_agent_close_keymaps(args.buf)
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd("BufWinEnter", {
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "terminal" then
          return
        end

        set_cursor_agent_close_keymaps(args.buf)
      end,
    })

    vim.keymap.set("v", "<leader>ca", ":CursorAgentSelection<CR>", { desc = "Cursor Agent: Send selection" })
    vim.keymap.set("n", "<leader>cA", ":CursorAgentBuffer<CR>", { desc = "Cursor Agent: Send buffer" })
  end,
}

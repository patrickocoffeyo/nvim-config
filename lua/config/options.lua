local o = vim.opt

-- UI-related options.
o.number = true                   -- Show line numbers.
o.cursorline = true               -- Highlight the current line.
o.colorcolumn = "80"              -- Show a vertical guide at 80 characters.

-- Tabs and indentation options.
o.tabstop = 2                    -- Number of spaces that a <Tab> counts for.
o.shiftwidth = 2                 -- Number of spaces to use for each step of autoindent.
o.expandtab = true               -- Use spaces instead of tabs. (Overridden for Go).

-- Search options.
o.ignorecase = true              -- Ignore case in search patterns.
o.smartcase = true               -- Override 'ignorecase' if search pattern contains uppercase letters.
o.incsearch = true               -- Show search matches as you type.
o.hlsearch = true                -- Highlight all search matches.

-- Behavioral options.
o.clipboard = "unnamedplus"      -- Use system clipboard for all operations.
o.wrap = false                   -- Disable line wrapping.
o.timeoutlen = 400               -- Time to wait for a mapped sequence to complete (in milliseconds).
o.splitright = true              -- New vertical splits will be to the right of the current window.
o.splitbelow = true              -- New horizontal splits will be below the current window.
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize"
o.autoread = true                -- Reload unchanged buffers after files are updated outside Neovim.

-- Performance options.
o.updatetime = 250          -- faster update time
o.swapfile = false          -- don't create swap files
o.termguicolors = true      -- full color support

-- File encoding options.
o.encoding = "utf-8"
o.fileencoding = "utf-8"

-- Check files changed by agent terminals or other external tools when focus
-- returns to an editing window. Autoread reloads only unmodified buffers, so
-- local unsaved edits are never silently replaced.
local external_change_group = vim.api.nvim_create_augroup("CheckExternalFileChanges", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "WinEnter", "TermLeave" }, {
  group = external_change_group,
  callback = function()
    vim.cmd("checktime")
  end,
})

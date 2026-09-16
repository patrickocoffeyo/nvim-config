local M = {}

-- Treat non-empty directory paths as startup/project buffers, not files to
-- preserve as the active editing target in a session.
local function is_directory(path)
  return path ~= "" and vim.fn.isdirectory(path) == 1
end

-- Return true only for normal file buffers that are useful to restore into.
-- Empty buffers, terminal buffers, plugin buffers, and directory buffers are
-- skipped so sessions do not reopen into a dead-looking window.
local function is_real_file_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or is_directory(name) then
    return false
  end

  return vim.bo[buf].buftype == ""
end

-- Collect listed file buffers ordered by recency. This gives the loader a
-- sensible fallback when a saved session only contains hidden file buffers.
local function recent_file_buffers()
  local buffers = vim.tbl_filter(function(info)
    return is_real_file_buffer(info.bufnr)
  end, vim.fn.getbufinfo({ buflisted = 1 }))

  table.sort(buffers, function(a, b)
    return a.lastused > b.lastused
  end)

  return buffers
end

-- Focus an existing real file window, or switch the current window to the most
-- recently used file buffer. This keeps Persistence from saving/restoring a
-- session with only an empty, directory, or plugin buffer visible.
function M.focus_file_window()
  if is_real_file_buffer(0) then
    return true
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if is_real_file_buffer(buf) then
        vim.api.nvim_set_current_win(win)
        return true
      end
    end
  end

  local buffers = recent_file_buffers()
  if #buffers == 0 then
    return false
  end

  vim.cmd("buffer " .. buffers[1].bufnr)
  return true
end

-- Load a Persistence session, then repair the active window if the saved
-- session lands on an empty/directory buffer instead of a real file.
function M.load(opts)
  require("persistence").load(opts)
  M.focus_file_window()
end

-- Open Persistence's session picker. Selection itself stays delegated to the
-- plugin because it already handles listing and cwd switching.
function M.select()
  require("persistence").select()
end

-- Disable Persistence autosave for the current Neovim process. Useful for
-- quick edits or experiments that should not replace the project session.
function M.stop()
  require("persistence").stop()
  vim.notify("Session saving disabled")
end

-- Register guards around Persistence save/load events. The save hook makes
-- future sessions contain a visible file window; the load hook repairs older or
-- malformed sessions after Neovim finishes sourcing them.
function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "PersistenceSavePre",
    callback = function()
      M.focus_file_window()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "PersistenceLoadPost",
    callback = function()
      vim.schedule(M.focus_file_window)
    end,
  })
end

return M

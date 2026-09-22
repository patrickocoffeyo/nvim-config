local M = {}

local special_filetypes = {
  ["neo-tree"] = true,
  ["go-test-output"] = true,
  ["neotest-output"] = true,
  ["side-terminal"] = true,
}

-- Treat plugin panes and terminals as windows to close, not buffers to delete.
local function is_special_buffer(buf)
  return special_filetypes[vim.bo[buf].filetype] or vim.bo[buf].buftype == "terminal"
end

-- Floating windows do not count as editing layout splits.
local function is_floating_window(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

-- Count normal editing windows in the current tab, excluding plugin side panes.
local function regular_window_count()
  local count = 0

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) and not is_floating_window(win) then
      local buf = vim.api.nvim_win_get_buf(win)

      if not is_special_buffer(buf) then
        count = count + 1
      end
    end
  end

  return count
end

-- Close the current view in a way that respects splits, special panes, and
-- Barbar buffer tabs. This backs both :q and <leader>bc.
function M.close_current()
  if is_special_buffer(0) then
    pcall(vim.cmd, "close")
    return
  end

  if regular_window_count() > 1 then
    pcall(vim.cmd, "close")
    return
  end

  local ok = pcall(vim.cmd, "BufferClose")
  if not ok then
    vim.cmd("bdelete")
  end
end

return M

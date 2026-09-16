local M = {}

local special_filetypes = {
  ["neo-tree"] = true,
  ["go-test-output"] = true,
  ["neotest-output"] = true,
  ["side-terminal"] = true,
}

local function is_special_buffer(buf)
  return special_filetypes[vim.bo[buf].filetype] or vim.bo[buf].buftype == "terminal"
end

local function is_floating_window(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

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

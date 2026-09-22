local M = {}

local terminal = {
  buf = nil,
  win = nil,
  job = nil,
}

-- Return true when the saved side-terminal window can still be targeted.
local function is_valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

-- Return true when the saved terminal buffer still exists.
local function is_valid_buffer(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

-- Check whether the shell job is still running without blocking the UI.
local function job_is_alive(job)
  if not job or job == 0 then
    return false
  end

  local ok, result = pcall(vim.fn.jobwait, { job }, 0)
  return ok and type(result) == "table" and result[1] == -1
end

-- The terminal should be an approprately-sized right sidebar.
local function terminal_width()
  return math.max(32, math.floor(vim.o.columns * 0.28))
end

-- Add terminal-local escape hatches so the sidebar is easy to dismiss.
local function set_terminal_keymaps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set({ "n", "t" }, "<C-q>", function()
    -- Require the module at call time so the buffer-local map survives reloads.
    require("config.terminal").close()
  end, vim.tbl_extend("force", opts, { desc = "Close side terminal" }))

  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, { desc = "Leave terminal mode" }))
end

-- Create a fresh terminal buffer and start the user's shell inside it.
local function create_terminal_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(terminal.win, buf)

  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "side-terminal"

  terminal.buf = buf
  terminal.job = vim.fn.jobstart(vim.o.shell, {
    cwd = vim.fn.getcwd(),
    term = true,
    on_exit = function()
      -- Mark the cached job as gone so the next open creates a fresh shell.
      terminal.job = nil
    end,
  })

  set_terminal_keymaps(buf)
end

-- Close the terminal window while keeping the buffer/job available for reuse.
function M.close()
  if is_valid_window(terminal.win) then
    vim.api.nvim_win_close(terminal.win, true)
  end

  terminal.win = nil
end

-- Open or focus the reusable right-hand terminal split.
function M.open()
  if is_valid_window(terminal.win) then
    vim.api.nvim_set_current_win(terminal.win)
    vim.cmd("startinsert")
    return
  end

  vim.cmd("botright vertical " .. terminal_width() .. "split")
  terminal.win = vim.api.nvim_get_current_win()

  if is_valid_buffer(terminal.buf) and job_is_alive(terminal.job) then
    vim.api.nvim_win_set_buf(terminal.win, terminal.buf)
  else
    create_terminal_buffer()
  end

  vim.cmd("startinsert")
end

-- Toggle the terminal split without killing the running shell.
function M.toggle()
  if is_valid_window(terminal.win) then
    M.close()
  else
    M.open()
  end
end

return M

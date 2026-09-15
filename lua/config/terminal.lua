local M = {}

local terminal = {
  buf = nil,
  win = nil,
  job = nil,
}

local function is_valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buffer(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function job_is_alive(job)
  if not job or job == 0 then
    return false
  end

  local ok, result = pcall(vim.fn.jobwait, { job }, 0)
  return ok and type(result) == "table" and result[1] == -1
end

local function terminal_width()
  return math.max(32, math.floor(vim.o.columns * 0.28))
end

local function set_terminal_keymaps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set({ "n", "t" }, "<C-q>", function()
    require("config.terminal").close()
  end, vim.tbl_extend("force", opts, { desc = "Close side terminal" }))

  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, { desc = "Leave terminal mode" }))
end

local function create_terminal_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(terminal.win, buf)

  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "side-terminal"

  terminal.buf = buf
  terminal.job = vim.fn.termopen(vim.o.shell, {
    cwd = vim.fn.getcwd(),
    on_exit = function()
      terminal.job = nil
    end,
  })

  set_terminal_keymaps(buf)
end

function M.close()
  if is_valid_window(terminal.win) then
    vim.api.nvim_win_close(terminal.win, true)
  end

  terminal.win = nil
end

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

function M.toggle()
  if is_valid_window(terminal.win) then
    M.close()
  else
    M.open()
  end
end

return M

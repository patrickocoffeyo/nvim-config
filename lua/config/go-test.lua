local M = {}

-- Neotest + nvim-coverage bridge for Go.
--
-- neotest-golang runs tests, but nvim-coverage reads a Go coverprofile from
-- disk. This helper gives every Go test run a package-local coverage.out, waits
-- for that file to change, loads it into the UI, then removes the generated
-- file so package directories stay clean.

local package_runs = {}
local output_panel = {
  buf = nil,
  win = nil,
  lines = { "No Go package test run yet." },
}

-- Return whether the reusable Go test output split is currently visible.
local function output_panel_valid()
  return output_panel.win and vim.api.nvim_win_is_valid(output_panel.win)
end

-- Create or reuse the scratch buffer that stores the latest package test output.
local function ensure_output_buffer()
  if output_panel.buf and vim.api.nvim_buf_is_valid(output_panel.buf) then
    return output_panel.buf
  end

  local buf = vim.api.nvim_create_buf(false, true)
  output_panel.buf = buf

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "go-test-output"
  vim.api.nvim_buf_set_name(buf, "Go package test output")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_panel.lines)
  vim.bo[buf].modifiable = false

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "q", function()
    M.close_output_panel()
  end, vim.tbl_extend("force", opts, { desc = "Close Go test output" }))
  vim.keymap.set("n", "<Esc>", function()
    M.close_output_panel()
  end, vim.tbl_extend("force", opts, { desc = "Close Go test output" }))

  return buf
end

-- Remove the final empty string produced by splitting output that ends in "\n".
local function trim_trailing_empty_line(lines)
  if #lines > 1 and lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

-- Split stdout/stderr into lines while preserving intentional blank lines.
local function split_output(text)
  if not text or text == "" then
    return {}
  end

  return trim_trailing_empty_line(vim.split(text:gsub("\r\n", "\n"), "\n", { plain = true }))
end

-- Replace the scratch buffer contents with the latest package test result.
local function render_output(lines)
  output_panel.lines = lines

  local buf = ensure_output_buffer()
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

-- Add a titled stdout/stderr section when the command produced content there.
local function append_section(lines, title, text)
  local output = split_output(text)
  if #output == 0 then
    return
  end

  table.insert(lines, "")
  table.insert(lines, title)
  vim.list_extend(lines, output)
end

-- Render the command as a single readable line for the output panel.
local function command_text(command)
  return table.concat(command, " ")
end

-- Build the stable header shown at the top of every package test result.
local function package_output_header(dir, command, status)
  return {
    "Go package tests: " .. vim.fn.fnamemodify(dir, ":~:."),
    "Command: " .. command_text(command),
    "Status: " .. status,
    "",
  }
end

-- Return the directory for the active/saved Go file; this is the package scope
-- used for save-triggered runs.
local function current_package_dir(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr or 0)
  if file == "" then
    return vim.uv.cwd()
  end

  return vim.fs.dirname(vim.fs.normalize(file))
end

-- Find the nearest Go workspace/module root for resolving coverprofile paths
-- back to real source files.
local function current_project_root(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr or 0)
  if file == "" then
    return vim.fs.root(vim.uv.cwd(), { "go.work", "go.mod", ".git" })
  end

  return vim.fs.root(vim.fs.normalize(file), { "go.work", "go.mod", ".git" })
end

-- Keep coverprofiles package-local so package runs do not trample each other.
local function coverage_file(dir)
  return dir .. "/coverage.out"
end

-- Capture enough file metadata to tell whether a coverprofile has been updated.
local function stat_signature(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end

  return {
    sec = stat.mtime.sec,
    nsec = stat.mtime.nsec,
    size = stat.size,
  }
end

-- Compare two stat snapshots while handling the initial "file missing" state.
local function changed(before, after)
  return after
    and (
      not before
      or after.sec ~= before.sec
      or after.nsec ~= before.nsec
      or after.size ~= before.size
    )
end

-- Delete the temporary coverprofile after nvim-coverage has read and placed it.
local function remove_coverage_file(path)
  vim.defer_fn(function()
    if vim.uv.fs_stat(path) then
      vim.uv.fs_unlink(path)
    end
  end, 1000)
end

-- Read the module path from go.mod so package import paths in coverage.out can
-- be converted back to paths relative to the project root.
local function module_name(root)
  if not root then
    return ""
  end

  local mod_file = root .. "/go.mod"
  if not vim.uv.fs_stat(mod_file) then
    return ""
  end

  for _, line in ipairs(vim.fn.readfile(mod_file)) do
    local name = line:match("^module%s+(.+)$")
    if name then
      return name
    end
  end

  return ""
end

-- Normalize a coverprofile filename by stripping the module import path prefix.
local function without_module_prefix(file, name)
  local prefix = name ~= "" and (name .. "/") or ""
  if prefix ~= "" and vim.startswith(file, prefix) then
    return file:sub(#prefix + 1)
  end

  return file
end

-- Add covered files as hidden buffers before placing signs. nvim-coverage only
-- creates signs for buffers Neovim knows about, and Go coverage usually points
-- at source files even when a _test.go file triggered the run.
local function preload_coverage_buffers(path, root)
  if not root or not vim.uv.fs_stat(path) then
    return
  end

  local name = module_name(root)
  local previous_cwd = vim.fn.getcwd(0)
  local changed_cwd = pcall(vim.cmd, "lcd " .. vim.fn.fnameescape(root))

  for _, line in ipairs(vim.fn.readfile(path)) do
    local file = line:match("^(.+):%d+%.%d+,%d+%.%d+ %d+ %d+$")
    if file then
      vim.fn.bufadd(without_module_prefix(file, name))
    end
  end

  if changed_cwd then
    pcall(vim.cmd, "lcd " .. vim.fn.fnameescape(previous_cwd))
  end
end

-- Load one exact coverprofile into nvim-coverage while scoped to the saved
-- buffer. This avoids races where another buffer is current when tests finish.
local function load_coverage_file(path, root, bufnr)
  local ok, coverage = pcall(require, "coverage")
  if ok then
    vim.g.go_test_coverage_file = path
    vim.api.nvim_buf_call(bufnr or 0, function()
      preload_coverage_buffers(path, root)
      coverage.load(true)
    end)
    vim.g.go_test_coverage_file = nil
  end

  remove_coverage_file(path)
end

-- Build an exact current-package test command. Using "." from the package
-- directory avoids adapter behavior that can expand some directories to ./...
local function package_test_command(path)
  if vim.fn.executable("gotestsum") == 1 then
    return {
      "gotestsum",
      "--format=standard-verbose",
      "--",
      "-v",
      "-count=1",
      "-coverprofile=" .. path,
      ".",
    }
  end

  return {
    "go",
    "test",
    "-v",
    "-count=1",
    "-coverprofile=" .. path,
    ".",
  }
end

-- Provide neotest-golang with coverage-enabled args for nearest/file/suite
-- runs, which still go through Neotest.
function M.coverage_args()
  local dir = current_package_dir()

  return {
    "-v",
    "-count=1",
    "-coverprofile=" .. coverage_file(dir),
  }
end

-- Show the reusable bottom split that displays current-package test output.
function M.open_output_panel(opts)
  opts = opts or {}

  local buf = ensure_output_buffer()
  if output_panel_valid() then
    if opts.enter ~= false then
      vim.api.nvim_set_current_win(output_panel.win)
    end
    return
  end

  local previous_win = vim.api.nvim_get_current_win()
  vim.cmd("botright 12split")
  output_panel.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(output_panel.win, buf)
  vim.api.nvim_win_set_height(output_panel.win, 12)

  if opts.enter == false and vim.api.nvim_win_is_valid(previous_win) then
    vim.api.nvim_set_current_win(previous_win)
  end
end

-- Close the reusable package test output split, keeping its buffer/results.
function M.close_output_panel()
  if output_panel_valid() then
    vim.api.nvim_win_close(output_panel.win, true)
  end
  output_panel.win = nil
end

-- Toggle the package test output split for quick access while editing.
function M.toggle_output_panel()
  if output_panel_valid() then
    M.close_output_panel()
  else
    M.open_output_panel()
  end
end

-- Poll briefly for a coverprofile written by a Neotest run, then load it into
-- the UI and remove the generated file.
function M.show_coverage_when_ready(dir, bufnr)
  local path = coverage_file(dir)
  local root = current_project_root(bufnr)
  local before = stat_signature(path)
  local timer = vim.uv.new_timer()

  if not timer then
    return
  end

  local attempts = 0
  timer:start(250, 250, function()
    attempts = attempts + 1
    local after = stat_signature(path)

    if changed(before, after) then
      timer:stop()
      timer:close()

      vim.schedule(function()
        load_coverage_file(path, root, bufnr)
      end)
    elseif attempts >= 80 then
      timer:stop()
      timer:close()
    end
  end)
end

-- Run the nearest Go test through Neotest, then load package-local coverage.
function M.run_nearest()
  local dir = current_package_dir()
  require("neotest").run.run()
  M.show_coverage_when_ready(dir, 0)
end

-- Run all tests in the current file through Neotest, then load coverage.
function M.run_file()
  local dir = current_package_dir()
  require("neotest").run.run(vim.fn.expand("%"))
  M.show_coverage_when_ready(dir, 0)
end

-- Run tests for exactly the current Go package. This is used on save so editing
-- one package does not kick off tests elsewhere in the module.
function M.run_package(bufnr, opts)
  opts = opts or {}

  local dir = current_package_dir(bufnr)
  local root = current_project_root(bufnr)
  local path = coverage_file(dir)
  local command = package_test_command(path)

  if package_runs[dir] then
    if opts.open_panel then
      M.open_output_panel({ enter = false })
    end
    return
  end

  package_runs[dir] = true
  render_output(package_output_header(dir, command, "running..."))

  if opts.open_panel then
    M.open_output_panel({ enter = false })
  end

  if vim.uv.fs_stat(path) then
    vim.uv.fs_unlink(path)
  end

  vim.system(command, { cwd = dir, text = true }, function(result)
    package_runs[dir] = nil

    vim.schedule(function()
      local status = result.code == 0 and "passed" or ("failed with exit code " .. result.code)
      local lines = package_output_header(dir, command, status)
      append_section(lines, "stdout:", result.stdout)
      append_section(lines, "stderr:", result.stderr)
      render_output(lines)

      if vim.uv.fs_stat(path) then
        load_coverage_file(path, root, bufnr)
      elseif result.code ~= 0 then
        vim.notify("Go package tests failed before coverage was written.", vim.log.levels.WARN)
      end
    end)
  end)
end

-- Run the full Neotest suite manually, then load coverage for the current
-- package if a package-local profile was produced.
function M.run_suite()
  local dir = current_package_dir()
  require("neotest").run.run({
    suite = true,
  })
  M.show_coverage_when_ready(dir, 0)
end

return M

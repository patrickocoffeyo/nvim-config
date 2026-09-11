local M = {}

-- Neotest + nvim-coverage bridge for Go.
--
-- neotest-golang runs tests, but nvim-coverage reads a Go coverprofile from
-- disk. This helper gives every Go test run a package-local coverage.out, waits
-- for that file to change, loads it into the UI, then removes the generated
-- file so package directories stay clean.

local package_runs = {}

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
function M.run_package(bufnr)
  local dir = current_package_dir(bufnr)
  local root = current_project_root(bufnr)
  local path = coverage_file(dir)

  if package_runs[dir] then
    return
  end

  package_runs[dir] = true
  if vim.uv.fs_stat(path) then
    vim.uv.fs_unlink(path)
  end

  vim.system(package_test_command(path), { cwd = dir, text = true }, function(result)
    package_runs[dir] = nil

    vim.schedule(function()
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

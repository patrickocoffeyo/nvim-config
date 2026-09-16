local buffers = require("config.buffers")
local go_test = require("config.go-test")
local format = require("config.format")
local terminal = require("config.terminal")

vim.api.nvim_create_user_command("CloseBuffer", function()
  buffers.close_current()
end, { desc = "Close current view or buffer tab" })

vim.cmd([[cnoreabbrev <expr> q getcmdtype() ==# ':' && getcmdline() ==# 'q' ? 'CloseBuffer' : 'q']])

vim.keymap.set("n", "<leader>uf", function()
  format.toggle()
end, { desc = "Toggle format on save" })

vim.keymap.set("n", "<leader>tt", function()
  terminal.toggle()
end, { desc = "Toggle side terminal" })

vim.keymap.set("n", "Z", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer tab" })
vim.keymap.set("n", "X", "<Cmd>BufferNext<CR>", { desc = "Next buffer tab" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

vim.keymap.set("n", "<leader>bp", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer tab" })
vim.keymap.set("n", "<leader>bn", "<Cmd>BufferNext<CR>", { desc = "Next buffer tab" })
vim.keymap.set("n", "<leader>bb", "<Cmd>BufferPick<CR>", { desc = "Pick buffer tab" })
vim.keymap.set("n", "<leader>bc", function()
  buffers.close_current()
end, { desc = "Close current view or buffer tab" })

vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

vim.keymap.set("n", "<leader>li", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.organizeImports" },
      diagnostics = {},
    },
  })
end, { desc = "Organize imports" })

vim.keymap.set("n", "<leader>tn", function()
  go_test.run_nearest()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
  go_test.run_file()
end, { desc = "Run file tests" })

vim.keymap.set("n", "<leader>tp", function()
  go_test.run_package(0, { open_panel = true })
end, { desc = "Run package tests with output" })

vim.keymap.set("n", "<leader>ta", function()
  go_test.run_suite()
end, { desc = "Run all tests" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
  go_test.toggle_output_panel()
end, { desc = "Toggle Go package test output" })

vim.keymap.set("n", "<leader>tO", function()
  require("neotest").output.open({ enter = true })
end, { desc = "Show Neotest output" })

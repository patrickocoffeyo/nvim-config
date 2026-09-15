local go_test = require("config.go-test")
local format = require("config.format")
local terminal = require("config.terminal")

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
vim.keymap.set("n", "<leader>bc", "<Cmd>BufferClose<CR>", { desc = "Close buffer tab" })

vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })

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
  go_test.run_package()
end, { desc = "Run package tests" })

vim.keymap.set("n", "<leader>ta", function()
  go_test.run_suite()
end, { desc = "Run all tests" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open({ enter = true })
end, { desc = "Show test output" })

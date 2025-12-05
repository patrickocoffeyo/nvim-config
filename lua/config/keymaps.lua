local neotest = require("neotest")

vim.keymap.set("n", "<leader>tn", function()
  neotest.run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run file tests" })

vim.keymap.set("n", "<leader>ta", function()
  neotest.run.run({ suite = true })
end, { desc = "Run all tests" })

vim.keymap.set("n", "<leader>ts", function()
  neotest.summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
  neotest.output.open({ enter = true })
end, { desc = "Show test output" })
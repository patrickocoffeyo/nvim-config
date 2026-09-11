local go_test = require("config.go-test")

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

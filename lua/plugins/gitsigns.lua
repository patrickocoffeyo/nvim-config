return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
      untracked = { text = "?" },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 500,
      ignore_whitespace = false,
      virt_text_priority = 100,
      use_focus = true,
    },
    current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      local function toggle(desc, action)
        return function()
          local enabled = action()
          vim.notify(desc .. ": " .. (enabled and "on" or "off"))
        end
      end

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next git hunk")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous git hunk")

      map("n", "<leader>gp", gitsigns.preview_hunk, "Preview git hunk")
      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, "Show git blame for line")
      map("n", "<leader>gB", gitsigns.blame, "Show git blame for buffer")
      map("n", "<leader>gd", gitsigns.diffthis, "Diff buffer against index")
      map("n", "<leader>gD", function()
        gitsigns.diffthis("~")
      end, "Diff buffer against previous commit")

      map("n", "<leader>gts", toggle("Git signs", gitsigns.toggle_signs), "Toggle git signs")
      map("n", "<leader>gtb", toggle("Git line blame", gitsigns.toggle_current_line_blame), "Toggle git line blame")
      map("n", "<leader>gtw", toggle("Git word diff", gitsigns.toggle_word_diff), "Toggle git word diff")
      map("n", "<leader>gtd", toggle("Git deleted lines", gitsigns.toggle_deleted), "Toggle git deleted lines")
    end,
  },
}

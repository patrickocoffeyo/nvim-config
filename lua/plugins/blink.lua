local copilot_tab = require("config.copilot-tab")

return {
  "saghen/blink.cmp",
  version = "*",
  build = "cargo build --release",
  event = "InsertEnter",
  opts = {
    signature = {
      enabled = true,
    },
    keymap = {
      preset = "none",
      ["<Tab>"] = {
        function(cmp)
          -- If a copilot suggestion is visible, accept it.
          if copilot_tab.accept_copilot() then return end

          -- If completion menu is visible, select next item.
          if cmp.is_menu_visible() then
            return cmp.select_next()
          end

          -- If a snippet can be expanded or jumped to, do that.
          if vim.snippet and vim.snippet.jumpable(1) then
            return vim.snippet.jump(1)
          end
        end,
        "fallback",
        mode = "i",
      },
      ["<CR>"] = {
        function(cmp)
          if cmp.is_menu_visible() then
            return cmp.select_and_accept()
          end
        end,
        "fallback",
        mode = "i",
      },
    },
  },
}

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
          -- If completion menu is visible, select next item.
          if cmp.is_menu_visible() then
            return cmp.select_next()
          end
        end,
        "snippet_forward",
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

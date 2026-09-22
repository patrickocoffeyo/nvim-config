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
        -- Prefer completion-menu navigation before falling back to snippets or
        -- a literal tab.
        function(cmp)
          if cmp.is_menu_visible() then
            return cmp.select_next()
          end
        end,
        "snippet_forward",
        "fallback",
        mode = "i",
      },
      ["<CR>"] = {
        -- Accept an explicit completion selection without changing normal
        -- Enter behavior when the menu is closed.
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

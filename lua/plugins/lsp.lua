return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "lua_ls", "ts_ls" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local util = require("lspconfig.util")
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

      vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = false,
        signs = true,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)


      -- Gopls language server.
      vim.lsp.start({
        name = "gopls",
        cmd = { mason_bin .. "gopls" },
        root_dir = util.root_pattern("go.mod", ".git"),
        capabilities = capabilities,
        settings = {
          gopls = {
            gofumpt = true,
            analyses = {
              unusedparams = true,
              unusedwrite = true,
              nilness = true,
            },
            staticcheck = true,
          },
        },
      })

      -- TypeScript language server.
      vim.lsp.start({
        name = "ts_ls",
        cmd = { mason_bin .. "typescript-language-server", "--stdio" },
        root_dir = util.root_pattern("package.json", ".git"),
        capabilities = capabilities,
      })
    end,
  },
}

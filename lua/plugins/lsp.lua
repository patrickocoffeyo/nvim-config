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
        ensure_installed = { "gopls", "golangci_lint_ls", "lua_ls", "ts_ls" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

      -- Prefer Mason-managed tools, but allow a project/system binary on PATH
      -- as a fallback. Returning nil lets optional integrations stay disabled
      -- instead of failing startup when a tool is not installed.
      local function executable(name)
        local path = mason_bin .. name
        if vim.fn.executable(path) == 1 then
          return path
        end

        if vim.fn.executable(name) == 1 then
          return name
        end

        return nil
      end

      vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = false,
        signs = true,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("gopls", {
        cmd = { mason_bin .. "gopls" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = capabilities,
        settings = {
          gopls = {
            completeFunctionCalls = true,
            completeUnimported = true,
            gofumpt = true,
            usePlaceholders = true,
          },
        },
      })
      vim.lsp.enable("gopls")

      if executable("golangci-lint-langserver") and executable("golangci-lint") then
        vim.lsp.config("golangci_lint_ls", {
          cmd = { executable("golangci-lint-langserver") },
          capabilities = capabilities,
        })
        vim.lsp.enable("golangci_lint_ls")
      end

      vim.lsp.config("lua_ls", {
        cmd = { mason_bin .. "lua-language-server" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      if vim.fn.executable("node") == 1 then
        vim.lsp.config("ts_ls", {
          cmd = { mason_bin .. "typescript-language-server", "--stdio" },
          root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
          capabilities = capabilities,
        })
        vim.lsp.enable("ts_ls")
      end
    end,
  },
}

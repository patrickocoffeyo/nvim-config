return {
  {
    "williamboman/mason.nvim",
    -- Mason owns external editor tools such as language servers and linters.
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    -- Keep the core language servers installed and available to lspconfig.
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "golangci_lint_ls", "lua_ls", "ts_ls" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    -- Configure each language server and connect blink.cmp capabilities.
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

      -- Use inline diagnostics and sign-column markers without updating while typing.
      vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = false,
        signs = true,
      })

      -- Reload externally changed buffers, then restart language servers attached
      -- to the current buffer. This gives gopls a fresh workspace after tools
      -- such as go generate add or rewrite project files.
      vim.api.nvim_create_user_command("LspRestart", function()
        vim.cmd("checktime")

        local names = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if vim.lsp.is_enabled(client.name) then
            names[client.name] = true
            client:stop(true)
          end
        end

        local enabled_names = vim.tbl_keys(names)
        if #enabled_names == 0 then
          vim.notify("No language servers are attached to this buffer.", vim.log.levels.WARN)
          return
        end

        vim.schedule(function()
          vim.lsp.enable(enabled_names)
          vim.notify("Restarted LSP: " .. table.concat(enabled_names, ", "))
        end)
      end, { desc = "Reload changed files and restart current LSP clients" })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Neovim disables workspace file watching by default on Linux. Opt gopls
      -- into it so changes to unopened Go files from go generate or agents are
      -- reported through the LSP protocol. With inotify-tools installed,
      -- Neovim uses inotifywait instead of its less capable fallback watcher.
      local gopls_capabilities = vim.deepcopy(capabilities)
      gopls_capabilities.workspace = gopls_capabilities.workspace or {}
      gopls_capabilities.workspace.didChangeWatchedFiles = {
        dynamicRegistration = true,
        relativePatternSupport = true,
      }

      -- Go language server: completion, auto-import suggestions, and gofumpt.
      vim.lsp.config("gopls", {
        cmd = { mason_bin .. "gopls" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = gopls_capabilities,
        settings = {
          gopls = {
            completeFunctionCalls = false,
            completeUnimported = true,
            gofumpt = true,
            usePlaceholders = false,
          },
        },
      })
      vim.lsp.enable("gopls")

      -- golangci-lint only starts when both the server and linter binaries exist.
      if executable("golangci-lint-langserver") and executable("golangci-lint") then
        vim.lsp.config("golangci_lint_ls", {
          cmd = { executable("golangci-lint-langserver") },
          capabilities = capabilities,
        })
        vim.lsp.enable("golangci_lint_ls")
      end

      -- Lua language server tuned for editing this Neovim config.
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

      -- TypeScript support is optional so non-Node environments still start cleanly.
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

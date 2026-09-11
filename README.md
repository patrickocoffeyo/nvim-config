# nvim-config

Personal Neovim config built around Lazy, Telescope, Tree-sitter, LSP, Go
tests/coverage, formatting, and Cursor Agent.

## Requirements

- Neovim 0.12 or newer.
- `rg`, used by Telescope live grep.
- `fd` or `fdfind`, used by Telescope file finding.
- Go toolchain, including `gofmt`.
- `tree-sitter`, used to install and maintain Tree-sitter parsers.
- Mason-managed Go tools: `gopls`, `golangci-lint`,
  `golangci-lint-langserver`, and `gotestsum`.
- `cursor-agent` on `$PATH` for Cursor Agent integration.
- Project-local or global `prettier`/`prettierd` for Prettier formatting.

## Installation

- Create a config directory: `mkdir -p ~/.config/nvim`.
- Clone this repository into the config directory:
  - `cd ~/.config/nvim`
  - `git clone git@github.com:patrickocoffeyo/nvim-config.git .`
- Open Neovim and run `:Lazy sync` to install plugins.
- Run `:Mason` to inspect language/tooling installs.

## Core Settings

General options live in `lua/config/options.lua`.

- Line numbers and cursorline are enabled.
- Tabs default to 2 spaces, with Go overriding indentation to real tabs and
  width 4 in `lua/ftplugin/go.lua`.
- Search uses ignorecase plus smartcase.
- System clipboard integration uses `unnamedplus`.
- Line wrapping and swapfiles are disabled.
- Splits open right and below.
- True color is enabled.
- `<Space>` is the leader key.

## Plugins

| Plugin | Config | Purpose |
| --- | --- | --- |
| `folke/lazy.nvim` | `lua/config/lazy.lua` | Plugin manager and bootstrapper. Imports every spec in `lua/plugins`. |
| `ellisonleao/gruvbox.nvim` | `lua/plugins/colorscheme.lua` | Dark gruvbox colorscheme. |
| `nvim-lualine/lualine.nvim` | `lua/plugins/lualine.lua` | Statusline with mode, branch, diff, filename, filetype, progress, and location. |
| `nvim-neo-tree/neo-tree.nvim` | `lua/plugins/neotree.lua` | File tree. Opens automatically on startup when no file argument is provided. |
| `nvim-telescope/telescope.nvim` | `lua/plugins/telescope.lua` | Fuzzy finding for files, grep, buffers, and help. |
| `nvim-telescope/telescope-fzf-native.nvim` | `lua/plugins/telescope.lua` | Native FZF sorter for Telescope. |
| `nvim-telescope/telescope-frecency.nvim` | `lua/plugins/telescope-frequency.lua` | Frecency-based Telescope extension, pinned to `^1.0.0` for compatibility. |
| `tami5/sqlite.lua` | `lua/plugins/telescope-frequency.lua` | SQLite dependency for Telescope frecency. |
| `saghen/blink.cmp` | `lua/plugins/blink.lua` | Completion engine, loaded on insert. Provides completion menu and signature help. |
| `neovim/nvim-lspconfig` | `lua/plugins/lsp.lua` | LSP client configuration for Go, Lua, TypeScript, and golangci-lint. |
| `williamboman/mason.nvim` | `lua/plugins/lsp.lua` | Installs and manages LSP servers, linters, and other external tools. |
| `williamboman/mason-lspconfig.nvim` | `lua/plugins/lsp.lua` | Bridges Mason packages to LSP config names. |
| `nvim-treesitter/nvim-treesitter` | `lua/plugins/treesitter.lua` | Tree-sitter parsing, highlighting, and indentation for configured languages. |
| `nvim-treesitter/nvim-treesitter-context` | `lua/plugins/treesitter-context.lua` | Sticky code context at the top of the window. |
| `windwp/nvim-ts-autotag` | `lua/plugins/treesitter-autotag.lua` | Auto-close and auto-rename paired HTML/TSX-style tags. |
| `nvim-neotest/neotest` | `lua/plugins/neotest.lua` | Test runner UI and commands. |
| `fredrikaverpil/neotest-golang` | `lua/plugins/neotest.lua` | Go adapter for Neotest. Uses `gotestsum`; duplicate subtest warnings are disabled. |
| `andythigpen/nvim-coverage` | `lua/plugins/nvim-coverage.lua` | Coverage signs in the gutter with gruvbox-compatible covered/uncovered colors. |
| `stevearc/conform.nvim` | `lua/plugins/format.lua` | Format-on-save for Go and project-configured Prettier filetypes. |
| `xTacobaco/cursor-agent.nvim` | `lua/plugins/cursor.lua` | Cursor Agent terminal and context-sending commands inside Neovim. |

Supporting dependencies include `nvim-lua/plenary.nvim`,
`nvim-tree/nvim-web-devicons`, `MunifTanjim/nui.nvim`,
`nvim-neotest/nvim-nio`, and `antoinemadec/FixCursorHold.nvim`.

## Keymaps

General:

- `<leader>uf`: toggle format-on-save for the current Neovim session.

Telescope:

- `<leader>ff`: find files.
- `<leader>fg`: live grep.
- `<leader>fb`: list buffers.
- `<leader>fh`: search help tags.

File tree:

- `<leader>e`: toggle Neo-tree on the left.
- `<leader>o`: focus Neo-tree on the left.

Go tests:

- `<leader>tn`: run the nearest test.
- `<leader>tf`: run tests in the current file.
- `<leader>tp`: run tests in the current package.
- `<leader>ta`: run the full test suite.
- `<leader>ts`: toggle the test summary.
- `<leader>to`: open test output.

Cursor Agent:

- `<leader>ca` in normal mode: toggle the Cursor Agent terminal.
- `<leader>ca` in visual mode: send the current selection to Cursor Agent.
- `<leader>cA` in normal mode: send the current buffer to Cursor Agent.

Completion:

- `<Tab>` in insert mode: select the next completion item when the menu is open,
  otherwise jump forward through snippets when possible.
- `<Enter>` in insert mode: accept the selected completion item when the menu is
  open, otherwise fall back to normal Enter behavior.

## Go Tests And Coverage

Go test keymaps are routed through `lua/config/go-test.lua`, which bridges
`neotest-golang` and `nvim-coverage`.

Manual nearest/file/suite test runs go through Neotest. Save-triggered package
runs use an exact package command from the saved file's directory:

- `gotestsum -- -v -count=1 -coverprofile=<package>/coverage.out .`
- fallback: `go test -v -count=1 -coverprofile=<package>/coverage.out .`

Each Go test run writes a package-local `coverage.out`, loads it into
`nvim-coverage`, shows the coverage signs, and then removes the generated
`coverage.out` file so the tree stays clean. The helper also preloads covered
source files as hidden buffers so coverage signs still work when a `_test.go`
file triggered the run.

## Go Linting

Go diagnostics come from two LSP clients:

- `gopls`: language server features and compiler diagnostics.
- `golangci_lint_ls`: lint diagnostics from `golangci-lint`.

`golangci_lint_ls` uses the nearest project config file supported by
`golangci-lint`, such as `.golangci.yml`, `.golangci.yaml`, `.golangci.toml`,
or `.golangci.json`. The extra `gopls` staticcheck-style lint analyzers are
left off so project lint policy lives in `golangci-lint`.

## Formatting

Format-on-save is enabled by default and managed by `conform.nvim`.

- Go files are formatted with `gofmt`.
- JavaScript, TypeScript, CSS, HTML, JSON, YAML, and Markdown use Prettier only
  when the project has a Prettier config file or a `prettier` key in
  `package.json`.
- `<leader>uf`: toggle format-on-save for the current Neovim session.

Conform is configured with `lsp_format = "never"` so only explicit formatters
run on save. Filetypes without a configured formatter quietly do nothing.

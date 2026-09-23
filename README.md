# nvim-config

Personal Neovim config built around Lazy, Telescope, Tree-sitter, LSP, Go
tests/coverage, formatting, Git blame, and a reusable side terminal.

## Requirements

- Neovim 0.12 or newer.
- `rg`, used by Telescope live grep.
- `fd` or `fdfind`, used by Telescope file finding.
- Go toolchain, including `gofmt`.
- `goimports`, used for Go format-on-save and import cleanup.
- `tree-sitter`, used to install and maintain Tree-sitter parsers.
- Mason-managed Go tools: `gopls`, `golangci-lint`,
  `golangci-lint-langserver`, and `gotestsum`.
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
- A vertical guide is shown at 80 characters.
- Tabs default to 2 spaces, with Go overriding indentation to real tabs and
  width 4 in `lua/ftplugin/go.lua`.
- Search uses ignorecase plus smartcase.
- System clipboard integration uses `unnamedplus`.
- Line wrapping and swapfiles are disabled.
- Splits open right and below.
- Sessions save buffers, current directory, folds, help windows, tab pages, and
  window sizes.
- True color is enabled.
- `<Space>` is the leader key.

## Plugins

| Plugin | Config | Purpose |
| --- | --- | --- |
| `folke/lazy.nvim` | `lua/config/lazy.lua` | Plugin manager and bootstrapper. Imports every spec in `lua/plugins`. |
| `ellisonleao/gruvbox.nvim` | `lua/plugins/colorscheme.lua` | Dark gruvbox colorscheme. |
| `romgrk/barbar.nvim` | `lua/plugins/barbar.lua` | Polished top tabline for buffers, with clickable tabs, slanted separators, and buffer picking. Neo-tree buffers are hidden from the tabline. |
| `nvim-lualine/lualine.nvim` | `lua/plugins/lualine.lua` | Statusline with mode, branch, diff, filename, filetype, progress, and location. |
| `lewis6991/gitsigns.nvim` | `lua/plugins/gitsigns.lua` | GitLens-style buffer integration with changed-line gutter signs, current-line blame, hunk previews, hunk navigation, and blame/diff views. |
| `linrongbin16/gitlinker.nvim` | `lua/plugins/gitlinker.lua` | Copies or opens GitHub-style permalinks for the current file line or selected range. |
| `nvim-mini/mini.map` | `lua/plugins/minimap.lua` | Toggleable code minimap with search, diagnostic, and Git hunk markers. |
| `folke/persistence.nvim` | `lua/plugins/persistence.lua` | Project-aware session autosave and explicit restore/select commands. Sessions are saved per working directory. |
| `nvim-neo-tree/neo-tree.nvim` | `lua/plugins/neotree.lua` | File tree. Opens automatically on startup when no file argument or one directory argument is provided. |
| `nvim-telescope/telescope.nvim` | `lua/plugins/telescope.lua` | Fuzzy finding for files, grep, buffers, and help. |
| `nvim-telescope/telescope-fzf-native.nvim` | `lua/plugins/telescope.lua` | Native FZF sorter for Telescope. |
| `nvim-telescope/telescope-frecency.nvim` | `lua/plugins/telescope-frequency.lua` | Frecency-based Telescope extension, pinned to `^1.0.0` for compatibility. |
| `tami5/sqlite.lua` | `lua/plugins/telescope-frequency.lua` | SQLite dependency for Telescope frecency. |
| `saghen/blink.cmp` | `lua/plugins/blink.lua` | Completion engine, loaded on insert. Provides completion menu and signature help. |
| `windwp/nvim-autopairs` | `lua/plugins/autopairs.lua` | Auto-inserts matching brackets, braces, quotes, and other paired characters while editing. |
| `neovim/nvim-lspconfig` | `lua/plugins/lsp.lua` | LSP client configuration for Go, Lua, TypeScript, and golangci-lint. |
| `williamboman/mason.nvim` | `lua/plugins/lsp.lua` | Installs and manages LSP servers, linters, and other external tools. |
| `williamboman/mason-lspconfig.nvim` | `lua/plugins/lsp.lua` | Bridges Mason packages to LSP config names. |
| `nvim-treesitter/nvim-treesitter` | `lua/plugins/treesitter.lua` | Tree-sitter parsing, highlighting, and indentation for configured languages. |
| `nvim-treesitter/nvim-treesitter-context` | `lua/plugins/treesitter-context.lua` | Sticky code context at the top of the window. |
| `windwp/nvim-ts-autotag` | `lua/plugins/treesitter-autotag.lua` | Auto-close and auto-rename paired HTML/TSX-style tags. |
| `MeanderingProgrammer/render-markdown.nvim` | `lua/plugins/markdown.lua` | Rendered Markdown view inside Neovim, with an optional side preview. |
| `nvim-neotest/neotest` | `lua/plugins/neotest.lua` | Test runner UI and commands. |
| `fredrikaverpil/neotest-golang` | `lua/plugins/neotest.lua` | Go adapter for Neotest. Uses `gotestsum`; duplicate subtest warnings are disabled. |
| `andythigpen/nvim-coverage` | `lua/plugins/nvim-coverage.lua` | Coverage signs in the gutter with gruvbox-compatible covered/uncovered colors. |
| `stevearc/conform.nvim` | `lua/plugins/format.lua` | Format-on-save for Go and project-configured Prettier filetypes. |
Supporting dependencies include `nvim-lua/plenary.nvim`,
`nvim-tree/nvim-web-devicons`, `MunifTanjim/nui.nvim`,
`nvim-neotest/nvim-nio`, and `antoinemadec/FixCursorHold.nvim`.

## Keymaps

General:

- `:q`: close the current split when multiple edit windows are open; otherwise
  close the current Barbar buffer tab. Special windows such as Neo-tree/test
  output/side terminal close as windows. `:q!`, `:qa`, and `:quit` keep their
  normal Vim behavior.
- `<leader>uf`: toggle format-on-save for the current Neovim session.
- `<leader>tt`: toggle a reusable terminal split on the right.
- `<leader>la`: show LSP code actions.
- `<leader>li`: organize imports for the current file.
- `gd`: go to the definition of the symbol under the cursor.
- `Z`: move to the previous Barbar buffer tab. This overrides Vim's default `ZZ`
  prefix behavior.
- `X`: move to the next Barbar buffer tab. This overrides Vim's default
  backward-delete key.

Window focus:

- `<C-h>`: focus the window to the left.
- `<C-j>`: focus the window below.
- `<C-k>`: focus the window above.
- `<C-l>`: focus the window to the right.

Buffer tabs:

- `<leader>bp`: move to the previous Barbar buffer tab.
- `<leader>bn`: move to the next Barbar buffer tab.
- `<leader>bb`: pick a Barbar buffer tab by letter.
- `<leader>bc`: close the current split when multiple edit windows are open;
  otherwise close the current Barbar buffer tab. Special windows close as
  windows.

Sessions:

- `<leader>ss`: restore the session for the current working directory.
- `<leader>sS`: select a saved session to restore.
- `<leader>sl`: restore the most recently saved session.
- `<leader>sd`: disable automatic session saving for the current Neovim
  instance.

Git:

- `]h`: move to the next changed Git hunk.
- `[h`: move to the previous changed Git hunk.
- `<leader>gp`: preview the current Git hunk.
- `<leader>gb`: show full blame for the current line.
- `<leader>gB`: open blame for the current buffer.
- `<leader>gd`: diff the current buffer against the index.
- `<leader>gD`: diff the current buffer against the previous commit.
- `<leader>gy`: copy a GitHub-style link for the current line or visual
  selection.
- `<leader>gY`: open a GitHub-style link for the current line or visual
  selection.
- `<leader>gts`: toggle Git signs in the sign column.
- `<leader>gtb`: toggle current-line blame.
- `<leader>gtw`: toggle word diff.
- `<leader>gtd`: toggle deleted-line display.

Terminal:

- `<leader>tt`: toggle the right-side terminal.
- `<C-q>` in the side terminal: close the terminal split.
- `<Esc>` in the side terminal: leave terminal mode.

Telescope:

- `<F1>`: find files.
- `<leader>ff`: find files.
- `<leader>fg`: search project text with ripgrep, including hidden files but
  excluding `.git`.
- `<leader>fG`: search project text with ripgrep, including hidden and ignored
  files but excluding `.git`.
- `<leader>fw`: search for the word under the cursor.
- `<leader>fr`: resume the previous Telescope picker.
- `<leader>fb`: list buffers.
- `<leader>fh`: search help tags.

Markdown:

- `<leader>mp`: toggle rendered Markdown in the current buffer.
- `<leader>mP`: open a rendered Markdown preview to the side.

Minimap:

- `<leader>mm`: toggle the right-side code minimap.

File tree:

- `<leader>e`: toggle Neo-tree on the left.
- `<leader>o`: focus Neo-tree on the left.
- `<Enter>` in Neo-tree: open the selected file in the current window as a
  Barbar buffer tab.
- `t` in Neo-tree: open the selected file in a native Vim tab page.
- `s` in Neo-tree: open the selected file in a vertical split.
- `S` in Neo-tree: open the selected file in a horizontal split.

Go tests:

- `<leader>tn`: run the nearest test.
- `<leader>tf`: run tests in the current file.
- `<leader>tp`: run tests in the current package and open the package output
  panel.
- `<leader>ta`: run the full test suite.
- `<leader>ts`: toggle the test summary.
- `<leader>to`: toggle the Go package test output panel.
- `<leader>tO`: open Neotest output for manual Neotest runs.
- `q` or `<Esc>` in test output panels: close the output window.

Completion:

- `<Tab>` in insert mode: select the next completion item when the menu is open,
  otherwise jump forward through snippets when possible.
- `<Enter>` in insert mode: accept the selected completion item when the menu is
  open, otherwise fall back to normal Enter behavior.
- Matching brackets, braces, quotes, and other paired characters are inserted
  automatically in insert mode.

## Go Tests And Coverage

Go test keymaps are routed through `lua/config/go-test.lua`, which bridges
`neotest-golang` and `nvim-coverage`.

Manual nearest/file/suite test runs go through Neotest. Package tests and
save-triggered runs use an exact package command from the saved file's
directory:

- `gotestsum -- -v -count=1 -coverprofile=<package>/coverage.out .`
- fallback: `go test -v -count=1 -coverprofile=<package>/coverage.out .`

Each Go test run writes a package-local `coverage.out`, loads it into
`nvim-coverage`, shows the coverage signs, and then removes the generated
`coverage.out` file so the tree stays clean. The helper also preloads covered
source files as hidden buffers so coverage signs still work when a `_test.go`
file triggered the run.

The package runner keeps its latest stdout/stderr in a reusable bottom panel.
Open it with `<leader>to`, run the current package with `<leader>tp`, and leave
it open while editing if you want save-triggered package runs to refresh in
place like a small VSCode-style Go test pane.

## Sessions

Sessions are managed by `persistence.nvim`. The plugin autosaves on exit once at
least one file buffer has been opened, but it does not automatically restore a
session on startup. Use `<leader>ss` after opening a project to restore the
session for the current directory.

Session save/load is wrapped by `lua/config/session.lua` so special startup
buffers do not become the main restored window. Before saving, the wrapper
focuses a real file buffer when one exists. After loading, it falls back to the
most recently used saved file buffer if the session lands on an empty or
directory buffer.

Session files live under Neovim's state directory, usually
`~/.local/state/nvim/sessions/`.

## Go Linting

Go diagnostics come from two LSP clients:

- `gopls`: language server features and compiler diagnostics.
- `golangci_lint_ls`: lint diagnostics from `golangci-lint`.

`golangci_lint_ls` uses the nearest project config file supported by
`golangci-lint`, such as `.golangci.yml`, `.golangci.yaml`, `.golangci.toml`,
or `.golangci.json`. The extra `gopls` staticcheck-style lint analyzers are
left off so project lint policy lives in `golangci-lint`.

`gopls` completion is configured with `completeUnimported` enabled, while
function-call completion and placeholders are disabled. That keeps symbol and
auto-import suggestions available without inserting full call signatures with
placeholder arguments.

## Formatting

Format-on-save is enabled by default and managed by `conform.nvim`.

- Go files prefer `goimports`, with `gofmt` as a fallback. `goimports` applies
  standard Go formatting and adds/removes imports.
- JavaScript, TypeScript, CSS, HTML, JSON, YAML, and Markdown use Prettier only
  when the project has a Prettier config file or a `prettier` key in
  `package.json`.
- `<leader>uf`: toggle format-on-save for the current Neovim session.

Conform is configured with `lsp_format = "never"` so only explicit formatters
run on save. Filetypes without a configured formatter quietly do nothing.

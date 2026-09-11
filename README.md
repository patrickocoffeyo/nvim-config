# nvim-config

## Requirements

- Install ripgrep (`rg`), used for searching files.
- Install fd-find (`fdfind`), used for finding files.

## Installation

- Create a config directory: `mkdir -p ~/.config/nvim`
- Clone this repository into the config directory:
  - `cd ~/.config/nvim`
  - `git clone git@github.com:patrickocoffeyo/nvim-config.git .`
- Open Neovim and run `:Lazy sync` to install plugins.

## Go Tests And Coverage

Go test keymaps are routed through `lua/config/go-test.lua`, which bridges
`neotest-golang` and `nvim-coverage`.

- `<leader>tn`: run the nearest test.
- `<leader>tf`: run tests in the current file.
- `<leader>tp`: run tests in the current package.
- `<leader>ta`: run the full test suite.
- `<leader>ts`: toggle the test summary.
- `<leader>to`: open test output.

Each Go test run writes a package-local `coverage.out`, loads it into
`nvim-coverage`, shows the coverage signs, and then removes the generated
`coverage.out` file.

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

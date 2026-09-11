local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.toml",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.ts",
  ".prettierrc.cts",
  ".prettierrc.mts",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
  "prettier.config.cts",
  "prettier.config.mts",
}

local function package_json_has_prettier(start)
  local package_json = vim.fs.find("package.json", {
    path = start,
    upward = true,
  })[1]

  if not package_json then
    return false
  end

  local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
  return ok and type(data) == "table" and data.prettier ~= nil
end

local function has_prettier_config(_, ctx)
  local filename = ctx and ctx.filename or vim.api.nvim_buf_get_name(0)
  local start = filename ~= "" and vim.fs.dirname(vim.fs.normalize(filename)) or vim.uv.cwd()

  return vim.fs.find(prettier_config_files, {
    path = start,
    upward = true,
  })[1] ~= nil or package_json_has_prettier(start)
end

return {
  "stevearc/conform.nvim",
  opts = function()
    local format = require("config.format")

    return {
      format_on_save = function()
        return format.on_save()
      end,

      formatters_by_ft = {
        go = { "goimports", "gofmt", stop_after_first = true },

        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
      },

      formatters = {
        prettier = {
          condition = has_prettier_config,
        },
        prettierd = {
          condition = has_prettier_config,
        },
      },
    }
  end,
}

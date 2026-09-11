local M = {}

M.enabled = true

function M.toggle()
  M.enabled = not M.enabled
  vim.notify("Format on save " .. (M.enabled and "enabled" or "disabled"))
end

function M.on_save()
  if not M.enabled then
    return nil
  end

  return {
    timeout_ms = 3000,
    lsp_format = "never",
    quiet = true,
  }
end

return M

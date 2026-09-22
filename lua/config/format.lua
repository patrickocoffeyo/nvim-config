local M = {}

M.enabled = true

-- Flip format-on-save for the current Neovim session.
function M.toggle()
  M.enabled = not M.enabled
  vim.notify("Format on save " .. (M.enabled and "enabled" or "disabled"))
end

-- Return Conform's per-save options, or nil to skip formatting.
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

local M = {}

-- Checks if Copilot inline suggestion is visible
local function has_copilot_suggestion()
  local ok, suggestion = pcall(require, "copilot.suggestion")
  return ok and suggestion.is_visible()
end

M.accept_copilot = function()
  if has_copilot_suggestion() then
    require("copilot.suggestion").accept()
    return true
  end
  return false
end

return M
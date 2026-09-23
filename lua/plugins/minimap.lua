return {
  "nvim-mini/mini.map",
  keys = {
    -- Keep the minimap available on demand without making it permanent UI.
    {
      "<leader>mm",
      function()
        require("mini.map").toggle()
      end,
      desc = "Toggle minimap",
    },
  },
  config = function()
    local minimap = require("mini.map")

    minimap.setup({
      integrations = {
        minimap.gen_integration.builtin_search(),
        minimap.gen_integration.diagnostic(),
        minimap.gen_integration.gitsigns(),
      },
      window = {
        side = "right",
        width = 10,
      },
    })
  end,
}

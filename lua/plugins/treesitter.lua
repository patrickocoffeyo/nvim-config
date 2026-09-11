local languages = {
  "go",
  "lua",
  "vim",
  "vimdoc",
  "javascript",
  "typescript",
  "tsx",
  "json",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = function()
    require("nvim-treesitter").install(languages):wait(300000)
  end,

  config = function()
    require("nvim-treesitter").setup()

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "go",
        "lua",
        "vim",
        "help",
        "javascript",
        "typescript",
        "typescriptreact",
        "json",
      },
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}

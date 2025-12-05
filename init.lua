-- Set <space> as the leader key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap config.
require("config.lazy")
require("config.options")
require("config.keymaps")
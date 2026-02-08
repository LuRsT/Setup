-- Common Configuration
require('config.common')

-- Keymaps
require('config.keymaps')

-- Plugins
require('config.plugins')

-- Colorscheme
require('config.colors')

-- Functions (if converted to Lua)
vim.cmd.source('~/.config/nvim/lua/config/functions.vim')

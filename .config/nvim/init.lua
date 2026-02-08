-- Common Configuration
require('config.common')

-- Plugin stuff
require('config.plugins')

-- Colorscheme
require('config.colors')

-- Functions (if converted to Lua)
--require('config.functions')
vim.cmd.source('~/.config/nvim/lua/config/functions.vim')

-- Common Configuration
require('config.common')

-- Lua stuff
require('config.lua')

-- Colorscheme
require('config.colors')

-- Functions (if converted to Lua)
--require('config.functions')
vim.cmd.source('~/.config/nvim/lua/config/functions.vim')

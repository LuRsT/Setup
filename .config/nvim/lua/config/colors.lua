-- Set background
vim.o.background = 'dark'

-- Set Gruvbox Material contrast
-- available values: 'hard', 'medium'(default), 'soft'
-- this must be set before loading the colorscheme
vim.g.gruvbox_material_background = 'medium'

-- Load colorscheme
vim.cmd.colorscheme('gruvbox-material')
--vim.cmd.colorscheme('austere')

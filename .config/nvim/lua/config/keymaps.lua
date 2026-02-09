-- Keep visual selection after indenting
vim.keymap.set('v', '>', '>gv', { desc = 'Indent and reselect' })
vim.keymap.set('v', '<', '<gv', { desc = 'Unindent and reselect' })

-- Navigate by paragraph with BS/CR
vim.keymap.set({'n', 'o', 'v'}, '<BS>', '{')
vim.keymap.set('v', '<CR>', '}')
vim.keymap.set({'n', 'o'}, '<CR>', function()
  return vim.bo.buftype == '' and '}' or '<CR>'
end, { expr = true })

-- Use tab and shift-tab to indent region (keep visual selection)
vim.keymap.set('n', '<Tab>', 'v>', { desc = 'Indent line' })
vim.keymap.set('n', '<S-Tab>', 'v<', { desc = 'Unindent line' })
vim.keymap.set('v', '<Tab>', '>gv', { desc = 'Indent selection' })
vim.keymap.set('v', '<S-Tab>', '<gv', { desc = 'Unindent selection' })

-- Use ; as :
vim.keymap.set('n', ';', ':', { desc = 'Command mode' })

-- Remove Q because who needs ex mode?
vim.keymap.set('n', 'Q', '<nop>', { desc = 'Disabled (Ex mode)' })

-- Display current filename
vim.keymap.set('n', '<C-x>', '<cmd>echo expand("%:p")<CR>', { desc = 'Show full path' })

-- Search for files with Telescope
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<C-g>', '<cmd>Telescope buffers<CR>', { desc = 'Switch buffers' })

-- Mark todo item as done
vim.keymap.set('', '<CR>', ':s/\\[ \\]/[X]/<CR>:nohl<CR>', { desc = 'Mark todo done' })

-- Use Neovim's built-in inspector (shows more info!)
vim.keymap.set('n', '<F3>', '<cmd>Inspect<CR>', { desc = 'Inspect highlight' })

-- Resize windows with Alt+hjkl
vim.keymap.set('n', '<a-j>', '<c-w>+', { desc = 'Increase window height' })
vim.keymap.set('n', '<a-k>', '<c-w>-', { desc = 'Decrease window height' })
vim.keymap.set('n', '<a-l>', '<c-w><', { desc = 'Decrease window width' })
vim.keymap.set('n', '<a-h>', '<c-w>>', { desc = 'Increase window width' })

-- Create new splits with Alt+Shift+hjkl
vim.keymap.set('n', '<a-J>', '<c-w>s<c-w>k', { desc = 'Split below and move up' })
vim.keymap.set('n', '<a-K>', '<c-w>s', { desc = 'Split below' })
vim.keymap.set('n', '<a-H>', '<c-w>v', { desc = 'Split right' })
vim.keymap.set('n', '<a-L>', '<c-w>v<c-w>h', { desc = 'Split right and move left' })

-- Quick fold toggle
vim.keymap.set('n', '<leader>z', 'za', { desc = 'Toggle fold' })
vim.keymap.set('n', '<leader>Z', 'zA', { desc = 'Toggle fold recursively' })


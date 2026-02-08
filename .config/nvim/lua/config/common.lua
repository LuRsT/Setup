-- Disable vi compatibility (not needed in Neovim, but kept for completeness)
vim.o.compatible = false

-- Terminal and colors
vim.o.termguicolors = true

-- Enable filetype detection, plugins, and indent
vim.cmd('filetype plugin indent on')

-- Basic editing options
vim.o.backspace = 'indent,eol,start'  -- BS past autoindents, line boundaries, and start of insertion
vim.o.cmdheight = 2
vim.o.incsearch = true
vim.o.inccommand = 'split'
vim.o.ruler = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.encoding = 'utf-8'
vim.o.updatetime = 500
vim.o.wildmenu = true
vim.o.number = true
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.gdefault = true
vim.o.backup = false
vim.o.swapfile = false
vim.o.autoindent = true
vim.o.showmatch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true
vim.o.shiftround = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.autowrite = true  -- Save buffer automatically when changing files
vim.o.fileformats = 'unix,mac,dos'  -- Handle Mac and DOS line-endings but prefer Unix

-- Wildignore patterns
vim.opt.wildignore:append({ '*/.git/*', '*/tmp/*', '*.swp' })

-- Autocommand: Delete trailing whitespaces on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = [[%s/\s\+$//e]]
})

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

-- Abbreviations
local abbrevs = {
  ['for@'] = 'for _ in x:',
  ['if@'] = 'if condition:',
  ['def@'] = 'def function_name():',
}

for lhs, rhs in pairs(abbrevs) do
  vim.cmd(string.format('iabbrev %s %s', lhs, rhs))
end

-- Use Neovim's built-in inspector (shows more info!)
vim.keymap.set('n', '<F3>', '<cmd>Inspect<CR>', { desc = 'Inspect highlight' })


vim.opt.signcolumn = 'yes'     -- Always show sign column (for LSP diagnostics)
vim.opt.termguicolors = true   -- Better colors in modern terminals
-- Folds
vim.opt.foldenable = false  -- Disable all folding
--vim.opt.foldmethod = 'expr'
--vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

-- File ignore patterns
vim.opt.wildignore:append({ '*.o', '*.pyc', '__pycache__', 'node_modules' })

-- Auto-save on focus lost (pairs well with autowrite)
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa"
})

vim.filetype.add({
  extension = {
    j2 = 'html',
  }
})

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/vim/undo_files')

-- Some common typos
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Qa', 'qa', {})
vim.api.nvim_create_user_command('QA', 'qa', {})
vim.api.nvim_create_user_command('Vs', 'vs', {})

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


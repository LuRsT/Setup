-- Enable filetype detection, plugins, and indent
vim.cmd('filetype plugin indent on')

-- Disable vi compatibility (not needed in Neovim, but kept for completeness)
vim.o.compatible = false

-- Terminal and colors
vim.o.termguicolors = true

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

vim.opt.signcolumn = 'yes'     -- Always show sign column (for LSP diagnostics)
vim.opt.termguicolors = true   -- Better colors in modern terminals

-- Fold settings
vim.opt.foldenable = false
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'  -- Lua function, not VimScript
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'expr'

-- File ignore patterns
vim.opt.wildignore:append({ '*.o', '*.pyc', '__pycache__', 'node_modules' })

-- Alias jinja files to html
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

-- Abbreviations
local abbrevs = {
  ['for@'] = 'for _ in x:',
  ['if@'] = 'if condition:',
  ['def@'] = 'def function_name():',
}

for lhs, rhs in pairs(abbrevs) do
  vim.cmd(string.format('iabbrev %s %s', lhs, rhs))
end

-- Autocommand: Delete trailing whitespaces on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = [[%s/\s\+$//e]]
})

-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa"
})

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

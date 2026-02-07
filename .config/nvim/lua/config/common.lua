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

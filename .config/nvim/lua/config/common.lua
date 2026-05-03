-- Set Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

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
vim.o.autowrite = true              -- Save buffer automatically when changing files
vim.o.fileformats = 'unix,mac,dos'  -- Handle Mac and DOS line-endings but prefer Unix

-- Wildignore patterns
vim.opt.wildignore:append({ '*/.git/*', '*/tmp/*', '*.swp' })

vim.opt.signcolumn = 'yes'     -- Always show sign column (for LSP diagnostics)

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
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo_files')

-- Some common typos
vim.api.nvim_create_user_command('W',  'w',  {})
vim.api.nvim_create_user_command('Q',  'q',  {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Qa', 'qa', {})
vim.api.nvim_create_user_command('QA', 'qa', {})
vim.api.nvim_create_user_command('Vs', 'vs', {})

-- Strip trailing whitespace on save.
-- Except for markdown
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'markdown' then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa"
})

-- Diagnostics: errors before warnings, rounded float, errors-only inline
vim.diagnostic.config({
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  virtual_text = {
    prefix = '●',
    severity = { min = vim.diagnostic.severity.ERROR },
  },
})

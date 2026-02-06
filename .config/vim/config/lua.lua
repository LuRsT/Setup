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

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "airblade/vim-gitgutter" },
    { "easymotion/vim-easymotion" },
    { "hotwatermorning/auto-git-diff" },
    { "itchyny/lightline.vim" },


    { "christoomey/vim-tmux-navigator" },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
            defaults = {
                layout_config = {
                width = 0.9,
                height = 0.6,
                },
                mappings = {
                i = {
                    ["<esc>"] = require("telescope.actions").close,
                },
                },
            },
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'LSP references' })
            vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
        end,
    },
    { "liuchengxu/vim-which-key" },
    {
        "machakann/vim-highlightedyank",
        config = function()
            vim.g.highlightedyank_highlight_duration = 200 -- ms
        end
    },
    { "norcalli/nvim-colorizer.lua" },
    { "plasticboy/vim-markdown" },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
    },
    {
    'stevearc/oil.nvim',
    config = function()
        require("oil").setup()
        vim.keymap.set("n", "-", "<cmd>Oil<cr>")
    end,
    },
    { "tpope/vim-commentary" },
    { "tpope/vim-fugitive" },
    { "tpope/vim-surround" },
    { "sainnhe/gruvbox-material" },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
    },

    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
  },
  -- Configure any other settings here. See the documentation for more details.
  --
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },

  -- automatically check for plugin updates
  checker = { enabled = true },
})


-- Mason setup (same as before)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright" },
})

-- New vim.lsp.config API
vim.lsp.config('*', {
  root_markers = { '.git' },
})

vim.lsp.config.pyright = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', '.git' },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      }
    }
  }
}

-- Enable LSP for Python files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.lsp.enable('pyright')
  end,
})

-- Keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf, noremap = true, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  end,
})

-- Tmux-navigator
vim.keymap.set('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>')
vim.keymap.set('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>')
vim.keymap.set('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>')
vim.keymap.set('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>')
vim.keymap.set('n', '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>')


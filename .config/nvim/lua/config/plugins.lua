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

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "airblade/vim-gitgutter" },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },
    { "hotwatermorning/auto-git-diff" },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
            theme = 'gruvbox-material',
            component_separators = { left = ':', right = '|' },
            section_separators = { left = '', right = '' },
            },
            sections = {
            lualine_a = { { 'mode', fmt = function(s) return s:sub(1,1) end } },
            lualine_b = { 'branch' },
            lualine_c = { { 'filename', symbols = { modified = '+', readonly = 'RO' } } },
            lualine_x = { 'encoding', 'fileformat', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = {
                    function()
                    if vim.bo.filetype == 'markdown' then
                        return vim.fn.wordcount().words .. 'w'
                    end
                    return ''
                    end,
                },
            },
        }
    },
    { "christoomey/vim-tmux-navigator" },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    sorting_strategy = 'ascending',  -- Results go top to bottom
                    layout_config = {
                        prompt_position = 'top',       -- Move prompt to top too
                        width = 0.9,
                        height = 0.6,
                    },
                    mappings = {
                        i = { -- Insert mode mappings
                            ["<esc>"] = require("telescope.actions").close,
                            ["<C-j>"] = require('telescope.actions').move_selection_next,
                            ["<C-k>"] = require('telescope.actions').move_selection_previous,
                            ["<C-h>"] = require('telescope.actions').select_horizontal,
                            ["<C-l>"] = require('telescope.actions').select_default,
                        },
                        n = {  -- Normal mode mappings
                            ["<C-j>"] = require('telescope.actions').move_selection_next,
                            ["<C-k>"] = require('telescope.actions').move_selection_previous,
                            ["<C-h>"] = require('telescope.actions').select_horizontal,
                            ["<C-l>"] = require('telescope.actions').select_default,
                        },
                    },
                },
            })
            local builtin = require("telescope.builtin")
            -- File shortcuts
            vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = 'Find files' })
            vim.keymap.set('n', '<leader>ff',       builtin.find_files, { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'LSP references' })
            vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })

            -- Git shortcuts
            vim.keymap.set('n', '<leader>gl', builtin.git_commits, { desc = 'Git log' })
            vim.keymap.set('n', '<leader>gb', builtin.git_commits, { desc = 'Git blame' })
            vim.keymap.set('n', '<leader>gs', builtin.git_commits, { desc = 'Git status' })

            -- Grep shortcuts
            vim.keymap.set('n', '<leader>rg', builtin.grep_string, { desc = 'Grep for string' })
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
            preset = "modern",
        })

        -- Define keymaps with descriptions
        vim.keymap.set('n', '<leader>vv', '<cmd>e ~/.config/nvim/init.lua<CR>', { desc = 'Edit init.lua' })
        vim.keymap.set('n', '<leader>ft', '<cmd>Neotree<CR>', { desc = 'File tree' })
        vim.keymap.set('n', '<leader>E', 'yyp:.!bash<CR>', { desc = 'Execute line as bash' })

        -- Register group names (this makes <leader>v show "Vim config" instead of "+3")
        wk.add({
            { "<leader>v", group = "Vim config" },
            { "<leader>f", group = "File/Find" },
            { "<leader>w", group = "Windows" },
            { "<leader>g", group = "Git" },
            { "<leader>c", group = "Code" },
        })
        end,
    },
    { "norcalli/nvim-colorizer.lua" },
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
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup()
            vim.keymap.set("n", "-", "<cmd>Oil<cr>")
        end,
    },
    { "tpope/vim-fugitive" },
    { "tpope/vim-surround" },
    { "sainnhe/gruvbox-material" },
    { 'lurst/austere.vim' },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        opts = {
            ensure_installed = { "python", "lua", "vim", "vimdoc", "markdown" },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
  },
  -- Configure any other settings here. See the documentation for more details.
  --
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },

  -- don't check for plugin updates
  checker = { enabled = false },
})


-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "basedpyright", "ruff" },
})

-- New vim.lsp.config API
vim.lsp.config('*', {
  root_markers = { '.git' },
})

vim.lsp.config.basedpyright = {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', '.git' },
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
      }
    }
  }
}

vim.lsp.config.ruff = {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
}

-- Built-in LSP completion (replaces nvim-cmp).
-- Nothing is preselected, so <CR> only accepts an item picked with <C-n>/<C-p>.
-- No 'fuzzy': it ranks basedpyright results badly ("Pat" put
-- PendingDeprecationWarning above pathlib.Path).
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

-- Servers only list a few trigger characters (like '.'). Adding the
-- identifier characters makes the menu open as you type, like nvim-cmp did.
local IDENTIFIER_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
local clients_with_identifier_triggers = {}

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method('textDocument/completion') then
      return
    end

    -- LspAttach fires once per buffer, but the capabilities are per client.
    if not clients_with_identifier_triggers[client.id] then
      local completion_provider = client.server_capabilities.completionProvider
      local trigger_chars = completion_provider.triggerCharacters or {}
      for index = 1, #IDENTIFIER_CHARS do
        local char = IDENTIFIER_CHARS:sub(index, index)
        table.insert(trigger_chars, char)
      end
      completion_provider.triggerCharacters = trigger_chars
      clients_with_identifier_triggers[client.id] = true
    end

    vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
  end,
})

vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, { desc = 'Trigger completion' })

-- Only <C-y> applies auto-imports and expands snippets, so <CR> sends it
-- when an item is selected and inserts a newline otherwise.
vim.keymap.set('i', '<CR>', function()
  local menu_is_open = vim.fn.pumvisible() == 1
  local selected_index = vim.fn.complete_info({ 'selected' }).selected
  if menu_is_open and selected_index ~= -1 then
    return '<C-y>'
  end
  return '<CR>'
end, { expr = true, desc = 'Accept selected completion or newline' })

-- Tmux-navigator
vim.keymap.set('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>')
vim.keymap.set('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>')
vim.keymap.set('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>')
vim.keymap.set('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>')
vim.keymap.set('n', '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>')


-- Telescope cheatsheet
-- :Telescope buffers           -- Switch between open buffers
-- :Telescope oldfiles          -- Recently opened files
-- :Telescope command_history   -- Search command history and re-run
-- :Telescope search_history    -- Previous search patterns
-- :Telescope marks             -- Jump to marks
-- :Telescope registers         -- Browse and paste from registers
-- :Telescope jumplist          -- Navigate jump list
-- :Telescope vim_options       -- Search and set Vim options
-- :Telescope keymaps           -- Search all keybindings
-- :Telescope colorscheme       -- Preview and switch colorschemes
-- :Telescope highlights        -- Browse highlight groups
--
-- :Telescope lsp_references           -- Find all references
-- :Telescope lsp_definitions          -- Jump to definitions
-- :Telescope lsp_implementations      -- Find implementations
-- :Telescope lsp_document_symbols     -- Outline/symbols in current file
-- :Telescope lsp_workspace_symbols    -- Search symbols across workspace
-- :Telescope diagnostics              -- Browse errors/warnings
--
-- :Telescope git_commits       -- Browse commit history with diff preview
-- :Telescope git_bcommits      -- Commits for current buffer
-- :Telescope git_branches      -- Switch branches
-- :Telescope git_status        -- Interactive git status (stage/unstage files)
-- :Telescope git_stash         -- Browse and apply stashes


-- Open up floats to see hints/warnings/errors pop ups
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

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
    { "christoomey/vim-tmux-navigator" },
    { "dense-analysis/ale" },
    { "easymotion/vim-easymotion" },
    { "editorconfig/editorconfig-vim" },
    { "hotwatermorning/auto-git-diff" },
    { "itchyny/lightline.vim" },
    { "junegunn/fzf" },
    { "junegunn/fzf.vim" },
    { "liuchengxu/vim-which-key" },
    { "machakann/vim-highlightedyank" },
    { "norcalli/nvim-colorizer.lua" },
    { "plasticboy/vim-markdown" },
    { "scrooloose/nerdtree" },
    { "tpope/vim-commentary" },
    { "tpope/vim-fugitive" },
    { "tpope/vim-surround" },
    { "sainnhe/gruvbox-material" },
  },
  -- Configure any other settings here. See the documentation for more details.
  --
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },

  -- automatically check for plugin updates
  checker = { enabled = true },
})


vim.lsp.config('pylsp', {
    settings = {
        pylsp = {
            cmd = { 'pylsp' },
            plugins = {
                -- Disable default linter
            }
        }
    }
})

vim.lsp.enable('pylsp')

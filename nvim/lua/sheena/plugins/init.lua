local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
-- local g = vim.g      -- a table to access global variables
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

return require('packer').startup(function(use)
  use 'sheenazien8/GoToWorkspace.nvim'
  -- Packer can manage itself
  use {'wbthomason/packer.nvim', opt = true}
  use 'jiangmiao/auto-pairs'
  use 'editorconfig/editorconfig-vim'
  use 'christoomey/vim-tmux-navigator'
  use { 'mattn/emmet-vim' }
  -- use "lukas-reineke/indent-blankline.nvim"
  use { 'numToStr/Comment.nvim' }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use { 'vimwiki/vimwiki' }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'tpope/vim-dadbod' }
  use { 'tpope/vim-surround' }
  use { 'rcarriga/nvim-notify' }
  use {
    'phaazon/hop.nvim',
    branch = 'v1', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = '' }
    end
  }

  -- treesiter plugins
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'andymass/vim-matchup' }
  use { "folke/twilight.nvim" }
  use {
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter"
  }
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  -- LSP
  use 'neovim/nvim-lspconfig' -- Collection of configurations for the built-in LSP client
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'williamboman/nvim-lsp-installer'
  use 'nanotee/sqls.nvim'
  use 'lighttiger2505/sqls.vim'
  use {'akinsho/flutter-tools.nvim', requires = 'nvim-lua/plenary.nvim'}
  use 'mfussenegger/nvim-dap'
  use { 'jwalton512/vim-blade' }
  use { 'jparise/vim-graphql' }
  use { 'sbdchd/neoformat' }
  -- use { 'pierreglaser/folding-nvim' }
  -- snippet
  use {
    'SirVer/ultisnips',
    requires = {{'honza/vim-snippets', rtp = '.'}},
    config = function()
      vim.g.UltiSnipsRemoveSelectModeMappings = 0
    end
  }
  use 'quangnguyen30192/cmp-nvim-ultisnips'

  -- GIT
  use 'kdheepak/lazygit.nvim'
  use {
    'lewis6991/gitsigns.nvim',
    -- tag = 'release' -- To use the latest release
  }

  -- theme
  use 'morhetz/gruvbox'
  use 'folke/tokyonight.nvim'
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use({
    "catppuccin/nvim",
    as = "catppuccin"
  })
  use {
    'kdheepak/tabline.nvim',
    requires = { { 'hoob3rt/lualine.nvim', opt=true }, {'kyazdani42/nvim-web-devicons', opt = true} }
  }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    }
  }
end)

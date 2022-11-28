local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
-- local g = vim.g      -- a table to access global variables
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

return require('packer').startup(function(use)
  -- Packer can manage itself
  -- Lua
  use { "folke/which-key.nvim" }
  use {'wbthomason/packer.nvim', opt = true}
  -- use 'jiangmiao/auto-pairs'
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
  -- use { 'ElPiloto/telescope-vimwiki.nvim', run = 'make' }
  use { 'tpope/vim-dadbod' }
  use { 'tpope/vim-surround' }
  use { 'tpope/vim-fugitive' }
  --[[ use { 'rcarriga/nvim-notify' } ]]
  use {
    'phaazon/hop.nvim',
    branch = 'v1', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = '' }
    end
  }
  -- Packer
  -- use({
  --   "folke/noice.nvim",
  --   config = function()
  --     require("noice").setup()
  --   end,
  --   requires = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     -- "rcarriga/nvim-notify",
  --   }
  -- })
  -- Lua
  -- use {
  --   "ahmedkhalf/project.nvim",
  --   config = function()
  --     require("project_nvim").setup {
  --       -- your configuration comes here
  --       -- or leave it empty to use the default settings
  --       -- refer to the configuration section below
  --     }
  --   end
  -- }

  -- treesiter plugins
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }
  use { 'andymass/vim-matchup' }
  use { "folke/twilight.nvim" }
  -- use {
    -- "SmiteshP/nvim-gps",
    -- requires = "nvim-treesitter/nvim-treesitter"
  -- }
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  -- LSP
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'MunifTanjim/prettier.nvim'
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
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
  use { 'jwalton512/vim-blade' }
  use { 'jparise/vim-graphql' }
  use { 'sbdchd/neoformat' }
  -- use { 'pierreglaser/folding-nvim' }
  -- snippet
  use({"L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*"})
  use { 'saadparwaiz1/cmp_luasnip' }
  use "rafamadriz/friendly-snippets"
  -- use 'github/copilot.vim'

  -- GIT
  use 'kdheepak/lazygit.nvim'
  use {
    'lewis6991/gitsigns.nvim',
    -- tag = 'release' -- To use the latest release
  }

  -- theme
  use { 'fgheng/winbar.nvim' }
  use 'marko-cerovac/material.nvim'
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
  use 'navarasu/onedark.nvim'
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

  use { 'kyazdani42/nvim-web-devicons' }
  -- use {'glepnir/dashboard-nvim'}

  -- use '~/example-plugin'
  use 'stepelu/lua-ljsqlite3'
  use 'stepelu/lua-xsys'
  use {
    '~/Documents/Code/my_project/luaPlugin/gotoworkspace',
  }
end)

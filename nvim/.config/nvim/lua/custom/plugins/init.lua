-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.filetype.add { extension = { str = 'javascript' } }

---@module 'lazy'
---@type LazySpec
return {
  { 'windwp/nvim-ts-autotag', opts = {} },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
  },
  { 'brenoprata10/nvim-highlight-colors', opts = {
    enable_tailwind = true,
  } },
  -- nvim v0.8.0
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
  {
    'gruvw/strudel.nvim',
    build = 'npm install puppeteer@^24 && npm install',
    config = function()
      require('strudel').setup {
        update_on_save = true,
        -- headless = true,
      }
    end,
    keys = {
      { '<leader>sl', function() require('strudel').launch() end, desc = 'Launch Strudel' },
      { '<leader>sq', function() require('strudel').quit() end, desc = 'Quit Strudel' },
      { '<leader>st', function() require('strudel').toggle() end, desc = 'Strudel Toggle Play/Stop' },
      { '<leader>su', function() require('strudel').update() end, desc = 'Strudel Update' },
      { '<leader>ss', function() require('strudel').stop() end, desc = 'Strudel Stop Playback' },
      { '<leader>sb', function() require('strudel').set_buffer() end, desc = 'Strudel set current buffer' },
      { '<leader>sx', function() require('strudel').execute() end, desc = 'Strudel set current buffer and update' },
    },
  },
}

-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- to treat strudel files as js
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
  {
    'benomahony/uv.nvim',
    -- Optional filetype to lazy load when you open a python file
    -- ft = { python }
    -- Optional dependency, but recommended:
    dependencies = {
      'folke/snacks.nvim' or 'nvim-telescope/telescope.nvim',
    },
    opts = {
      picker_integration = true,
    },
  },
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
  {
    'mrcjkb/rustaceanvim',
    -- To avoid being surprised by breaking changes,
    -- I recommend you set a version range
    version = '^9',
    -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
    -- No need for lazy.nvim to lazy-load it.
    lazy = false,
  },
  -- Arduino-Nvim
  {
    'yuukiflow/Arduino-Nvim',
    ft = 'arduino',
    opts = {},
    dependencies = {
      'nvim-telescope/telescope.nvim',
      -- optional: remove if you use Neovim's built-in LSP (>= 0.11)
      'neovim/nvim-lspconfig',
    },
  },
  -- p5.js
  {
    'prjctimg/p5.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      -- p5.nvim shells out to a hardcoded `python3` for its websocket dev server,
      -- so the venv holding `websockets` has to win on PATH. Homebrew's python is
      -- externally-managed (PEP 668) and can't host the module itself.
      -- Bootstrap: python3 -m venv ~/.local/venvs/p5 && ~/.local/venvs/p5/bin/pip install websockets
      local venv = vim.fn.expand '~/.local/venvs/p5'
      if vim.uv.fs_stat(venv .. '/bin/python3') then vim.env.PATH = venv .. '/bin:' .. vim.env.PATH end

      -- p5.nvim's .gitignore excludes `assets/inject/` then tries to re-include the
      -- scripts inside it -- a pattern git cannot honour, so no clone ever has them.
      -- server.py reads them into INJECT_LIVERELOAD / INJECT_CONSOLE and injects
      -- without complaint when they're empty, so live reload and `:P5 console` both
      -- silently do nothing. Install our replacements.
      local inject = vim.fn.stdpath 'data' .. '/lazy/p5.nvim/assets/inject'
      for _, name in ipairs { 'livereload.js', 'console.js' } do
        local src = vim.fn.stdpath 'config' .. '/assets/p5/' .. name
        local dst = inject .. '/' .. name
        if vim.uv.fs_stat(src) then
          local want = vim.fn.readfile(src)
          local have = vim.uv.fs_stat(dst) and vim.fn.readfile(dst) or nil
          if not have or table.concat(have, '\n') ~= table.concat(want, '\n') then
            vim.fn.mkdir(inject, 'p')
            vim.fn.writefile(want, dst)
          end
        end
      end

      -- NOTE: live_reload goes at the *top level*, not under `server`, despite what
      -- p5.nvim's own defaults table suggests. server.lua reads `S.config.live_reload`
      -- from the top level, and init.lua merges opts in wholesale — so anything nested
      -- under `server` never reaches the reader.
      require('p5').setup {
        live_reload = {
          enabled = true,
          port = 12002,
          debounce_ms = 300,
          watch_extensions = { '.js', '.css', '.html', '.json' },
          exclude_dirs = { '.git', 'node_modules', 'dist', 'build' },
        },
      }
    end,
  },
}

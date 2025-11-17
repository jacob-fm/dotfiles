return {
  -- add theme
  { "ellisonleao/gruvbox.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "Shatur/neovim-ayu" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu",
    },
  },
}

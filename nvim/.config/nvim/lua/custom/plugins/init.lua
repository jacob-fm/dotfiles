-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  { 'windwp/nvim-ts-autotag', opts = {} },
  { 'brenoprata10/nvim-highlight-colors', opts = {
    enable_tailwind = true,
  } },
}

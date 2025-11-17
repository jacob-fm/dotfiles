return {
  "Shatur/neovim-ayu",
  config = function()
    require("ayu").setup({
      overrides = {
        Normal = { bg = "None" },
        NormalFloat = { bg = "None" },
        ColorColumn = { bg = "None" },
        SignColumn = { bg = "None" },
        Folded = { bg = "None" },
        FoldColumn = { bg = "None" },
        CursorLine = { bg = "None" },
        CursorColumn = { bg = "None" },
        VertSplit = { bg = "None" },
      },
    })

    -- enable theme
    require("ayu").colorscheme()
  end,
}

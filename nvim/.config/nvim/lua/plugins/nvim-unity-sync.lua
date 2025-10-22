return {
  "apyra/nvim-unity-sync",
  config = function()
    require("unity.plugin").setup({
      -- Configs here (Optional)
    })
  end,
  ft = "cs",
}

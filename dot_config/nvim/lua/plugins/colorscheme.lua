return {
  {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        float = {
          transparent = false,
          solid = false,
        },
        default_integrations = true,
        auto_integrations = true,
      })
    end,
  },
}

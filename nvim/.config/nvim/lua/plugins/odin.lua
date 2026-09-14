-- Odin: language server (ols) e syntax highlighting.
-- O binario instala-se a parte com: brew install ols
return {
  -- Highlighting e textobjects
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "odin" })
    end,
  },

  -- Language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- mason = false porque o ols vem do homebrew, tal como o odin.
        -- Assim as duas versoes andam a par, o que importa porque o ols
        -- analisa os packages do core: da instalacao do compilador.
        ols = { mason = false },
      },
    },
  },
}

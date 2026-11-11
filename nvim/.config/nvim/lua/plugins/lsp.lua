return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "shellcheck", -- picked up by bashls
        "hadolint",
        "sql-formatter",
        "prettier",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      -- mason-lspconfig enables installed servers automatically.
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "ruff",
          "bashls",
          "dockerls",
          "docker_compose_language_service",
          "yamlls",
          "jsonls",
          "ts_ls",
          "eslint",
        },
      })

      local map = vim.keymap.set
      map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
      map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      map("n", "<leader>gr", function() require("telescope.builtin").lsp_references() end, { desc = "References" })
      map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    end,
  },
}

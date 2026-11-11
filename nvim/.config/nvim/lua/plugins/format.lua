return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      -- Dockerfiles and compose files fall back to their language servers.
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        sql = { "sql_formatter" },
        lua = { "stylua" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
      formatters = {
        sql_formatter = { prepend_args = { "--language", "postgresql" } },
      },
    })
    vim.keymap.set({ "n", "v" }, "<leader>gf", function()
      require("conform").format({ lsp_format = "fallback" })
    end, { desc = "Format" })
  end,
}

-- nvim-treesitter `main` branch: parsers are compiled locally, so this needs the
-- tree-sitter CLI and a C compiler.
local parsers = {
  "lua", "vim", "vimdoc", "query",
  "python", "bash", "sql",
  "javascript", "typescript", "tsx", "jsdoc",
  "json", "yaml", "toml", "markdown", "markdown_inline", "html",
  "dockerfile", "gitignore", "regex",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}

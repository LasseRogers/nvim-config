return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      dockerfile = { "hadolint" },
    }

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      callback = function()
        -- Only run linters that are installed, so a fresh setup doesn't error
        -- before Mason has finished.
        for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
          local cmd = lint.linters[name].cmd
          if type(cmd) == "function" then cmd = cmd() end
          if vim.fn.executable(cmd) == 1 then lint.try_lint(name) end
        end
      end,
    })
  end,
}

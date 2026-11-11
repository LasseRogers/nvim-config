return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  keys = {
    { "<leader>cv", "<cmd>CsvViewToggle<CR>", desc = "Toggle CSV view" },
  },
  opts = {
    parser = { comments = { "#", "//" } },
    view = {
      display_mode = "border",
      sticky_header = { enabled = true },
    },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
  },
  config = function(_, opts)
    local csvview = require("csvview")
    csvview.setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function(e) csvview.enable(e.buf) end,
    })
    -- The FileType event for the buffer that triggered the load has already fired.
    if vim.tbl_contains({ "csv", "tsv" }, vim.bo.filetype) then csvview.enable(0) end
  end,
}

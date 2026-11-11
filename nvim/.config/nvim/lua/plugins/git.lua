return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>gt", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle blame" })
      vim.keymap.set("n", "<leader>gv", function()
        -- Toggle: close the gitsigns:// side if a diff is open, otherwise open one.
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match("^gitsigns://") then
            vim.api.nvim_win_close(win, true)
            vim.cmd("diffoff!")
            return
          end
        end
        require("gitsigns").diffthis()
      end, { desc = "Toggle diff against HEAD" })
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>lg", "<cmd>LazyGit<CR>", desc = "LazyGit" } },
  },
}

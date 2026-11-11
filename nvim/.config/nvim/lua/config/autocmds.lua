vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

-- Back to the dashboard once the last file buffer is closed.
local function has_file_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    vim.schedule(function()
      if has_file_buffers() then return end
      -- Pick an editor window, not neo-tree; if there is none, make one.
      local target
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= "neo-tree" and vim.api.nvim_win_get_config(win).relative == "" then
          target = win
          break
        end
      end
      if not target then
        vim.cmd("botright vnew")
        target = vim.api.nvim_get_current_win()
      end
      vim.api.nvim_set_current_win(target)
      if vim.bo.filetype ~= "alpha" then vim.cmd("Alpha") end
    end)
  end,
})

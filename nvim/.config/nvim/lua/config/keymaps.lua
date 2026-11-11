local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
-- Keeps the window (and the file tree next to it) instead of closing it like :bd.
-- In a terminal it only hides the window; deleting the buffer would kill the shell.
map("n", "<leader>x", function()
  if vim.bo.buftype == "terminal" then
    pcall(vim.cmd.hide)
  else
    Snacks.bufdelete()
  end
end, { desc = "Close buffer" })

-- Show and focus the terminal, or hide it when already focused. A terminal whose
-- shell has exited is wiped first, so this always lands in a working shell.
map("n", "<leader>t", function()
  for _, term in ipairs(Snacks.terminal.list()) do
    local job = vim.b[term.buf].terminal_job_id
    if not job or vim.fn.jobwait({ job }, 0)[1] ~= -1 then
      vim.api.nvim_buf_delete(term.buf, { force = true })
    end
  end
  Snacks.terminal.focus()
  if vim.bo.buftype == "terminal" then vim.cmd.startinsert() end
end, { desc = "Terminal" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Terminal mode. <C-\><C-n> isn't reachable on a Nordic layout, hence <Esc><Esc>.
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-h>", [[<C-\><C-n><C-w>h]])
map("t", "<C-j>", [[<C-\><C-n><C-w>j]])
map("t", "<C-k>", [[<C-\><C-n><C-w>k]])
map("t", "<C-l>", [[<C-\><C-n><C-w>l]])

-- Image rendering needs the kitty graphics protocol. Ghostty sets GHOSTTY_RESOURCES_DIR,
-- and tmux forwards it (see update-environment in .tmux.conf).
local has_graphics = vim.env.GHOSTTY_RESOURCES_DIR ~= nil or vim.env.KITTY_WINDOW_ID ~= nil

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    image = { enabled = has_graphics },
  },
}

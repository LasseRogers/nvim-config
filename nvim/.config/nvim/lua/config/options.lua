vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.wrap = false
opt.termguicolors = true

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true
opt.undofile = true
opt.updatetime = 250
opt.clipboard = "unnamedplus"
opt.mouse = "a"

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Compose files need their own filetype for docker_compose_language_service.
vim.filetype.add({
  pattern = {
    [".*/docker%-compose[%w%.%-]*%.ya?ml"] = "yaml.docker-compose",
    [".*/compose[%w%.%-]*%.ya?ml"] = "yaml.docker-compose",
  },
})

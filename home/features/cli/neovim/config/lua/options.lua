-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false

-- Always use the git root for project scope (avoids LSP/package roots in monorepos).
vim.g.root_spec = { ".git" }

vim.opt.spelllang = { "en", "fr" }

vim.opt.relativenumber = false

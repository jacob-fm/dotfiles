-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- bufferline: go to different tabs
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer" .. i .. "<cr>", { silent = true })
end
vim.keymap.set("n", "<leader>$", "<cmd>BufferLineGoToBuffer -1<cr>", { silent = true })

-- Saving
-- Normal mode
vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { silent = true })

-- Insert mode (goes to normal mode and then saves)
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<cr>", { silent = true })

-- Visual mode (writes and restores visual selection)
vim.keymap.set("v", "<C-s>", "<cmd>w<cr>", { silent = true })

-- Window navigation with leader key
vim.keymap.set("n", "<leader>w", "<C-w>", { silent = true }) -- leader W acts as ctrl w generally

-- LazyGit
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { noremap = true, silent = true })

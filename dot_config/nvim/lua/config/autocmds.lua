-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

-- Disable the spell checking in markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "markdown" },
  callback = function()
    vim.opt.spell = false
  end,
})

-- -- Disable the copilot suggestions in some files formats
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "text", "markdown", "toml", "yaml" },
--   command = "Copilot suggestion",
-- })

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  pattern = { "*.czrc" },
  callback = function()
    vim.bo.filetype = "json"
  end,
})

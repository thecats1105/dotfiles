local discipline = require("craftzdog.discipline")

-- Uncomment the following line to enable cowboy
-- discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')
keymap.set("v", "<Leader>p", '"0p')
keymap.set("n", "<Leader>c", '"_c')
keymap.set("n", "<Leader>C", '"_C')
keymap.set("v", "<Leader>c", '"_c')
keymap.set("v", "<Leader>C", '"_C')
keymap.set("n", "<Leader>d", '"_d')
keymap.set("n", "<Leader>D", '"_D')
keymap.set("v", "<Leader>d", '"_d')
keymap.set("v", "<Leader>D", '"_D')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
keymap.set("n", "<A-.>", ":tabnext<Return>", opts)
keymap.set("n", "<A-,>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, opts)

keymap.set("n", "<leader>r", function()
  require("craftzdog.hsl").replaceHexWithHSL()
end)

keymap.set("n", "<leader>i", function()
  require("craftzdog.lsp").toggleInlayHints()
end)

vim.api.nvim_create_user_command("ToggleAutoformat", function()
  require("craftzdog.lsp").toggleAutoformat()
end, {})

-- Disable comamnd history
keymap.set("n", "q:", "<Nop>", opts)
keymap.set("n", "q/", "<Nop>", opts)

-- Move tab
local function move_tab(step)
  local current_tab = vim.fn.tabpagenr()
  local total_tabs = vim.fn.tabpagenr("$")

  if total_tabs <= 1 then
    return
  end

  if step < 0 and current_tab == 1 then
    vim.cmd("tabmove $")
  elseif step > 0 and current_tab == total_tabs then
    vim.cmd("tabmove 0")
  else
    vim.cmd("tabmove" .. (step > 0 and "+1" or "-1"))
  end
end

keymap.set("n", "<A-<>", function()
  move_tab(-1)
end, opts)
keymap.set("n", "<A->>", function()
  move_tab(1)
end, opts)

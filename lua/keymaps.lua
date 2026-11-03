local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

map('n', '<leader>xx', vim.diagnostic.setqflist, { desc = 'Diagnostics to quickfix' })
map('n', '<leader>xX', function()
  vim.diagnostic.setloclist { bufnr = 0 }
end, { desc = 'Buffer diagnostics to loclist' })

map('n', '<leader>u', '<cmd>Undotree<CR>', { desc = 'Undo tree' })

-- change/substitute don't overwrite the clipboard (black hole register).
for _, key in ipairs { 'c', 'C', 's', 'S' } do
  map('x', key, '"_' .. key)
  map('n', key, '"_' .. key)
end

map('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })
map('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })
map('i', '<C-Space>', function()
  vim.lsp.completion.get()
end, { desc = 'Trigger LSP completion' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

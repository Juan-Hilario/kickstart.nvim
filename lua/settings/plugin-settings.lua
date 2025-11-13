-- Neotree Keymap
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>')

-- Emmet Keymap
vim.api.nvim_set_keymap('i', '<S-Tab>', '<Plug>(emmet-expand-abbr)', { noremap = true, silent = true })

vim.keymap.set('x', 's', '"_c', { desc = 'Replace selection' })

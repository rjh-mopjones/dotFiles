-- General keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- jk for escape in insert mode
keymap('i', 'jk', '<Esc>', opts)

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)
keymap('n', '<Tab>', '<C-w>w', opts)  -- Cycle through splits

-- Resize windows with arrows
keymap('n', '<C-Up>', ':resize +2<CR>', opts)
keymap('n', '<C-Down>', ':resize -2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Navigate buffers
keymap('n', 'X', ':bnext<CR>', opts)
keymap('n', 'Z', ':bprevious<CR>', opts)
keymap('n', '<leader>db', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Window splits
keymap('n', '<leader>vs', ':vsplit<CR>', { desc = 'Vertical split' })

-- Terminal integration
keymap('n', '<leader>tt', ':terminal<CR>', { desc = 'Open terminal' })
keymap('n', '<leader>tv', ':vsplit | terminal<CR>', { desc = 'Open terminal in vertical split' })
keymap('n', '<leader>th', ':split | terminal<CR>', { desc = 'Open terminal in horizontal split' })

-- Terminal mode keymaps
keymap('t', 'jk', '<C-\\><C-n>', opts)  -- Exit terminal mode with jk
keymap('t', '<C-h>', '<C-\\><C-n><C-w>h', opts)  -- Navigate left from terminal
keymap('t', '<C-j>', '<C-\\><C-n><C-w>j', opts)  -- Navigate down from terminal
keymap('t', '<C-k>', '<C-\\><C-n><C-w>k', opts)  -- Navigate up from terminal
keymap('t', '<C-l>', '<C-\\><C-n><C-w>l', opts)  -- Navigate right from terminal

-- Telescope keymaps
local telescope_builtin = require('telescope.builtin')
keymap('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Find files' })
keymap('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Live grep' })
keymap('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Find buffers' })
keymap('n', '<leader>fh', telescope_builtin.help_tags, { desc = 'Help tags' })
keymap('n', '<leader>fr', telescope_builtin.lsp_references, { desc = 'Find references' })

-- NvimTree toggle
keymap('n', 'tt', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- LSP Diagnostics (for squiggly lines)
keymap('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
keymap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
keymap('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
keymap('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostic list' })

-- Clear search highlighting
keymap('n', '<leader>h', ':nohlsearch<CR>', opts)

-- Save, quit, and close shortcuts
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>q', ':q<CR>', opts)
keymap('n', '<leader>cs', ':close<CR>', opts)

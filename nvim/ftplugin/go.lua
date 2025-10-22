-- Go-specific configuration with gopls

-- Configure gopls (Go Language Server) using the new vim.lsp.config API
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      matcher = "fuzzy",
      symbolMatcher = "fuzzy",
      semanticTokens = true,
      codelenses = {
        generate = true,
        gc_details = true,
        test = true,
        tidy = true,
        vendor = true,
        upgrade_dependency = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- Enable gopls for this buffer
vim.lsp.enable('gopls')

-- LSP keymaps
local bufopts = { noremap=true, silent=true, buffer=true }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

-- Go-specific commands
vim.keymap.set('n', '<leader>gi', ':GoImport<CR>', bufopts)
vim.keymap.set('n', '<leader>gt', ':GoTestFunc<CR>', bufopts)  -- lowercase t = current test
vim.keymap.set('n', '<leader>gT', ':GoTest<CR>', bufopts)       -- uppercase T = all tests
vim.keymap.set('n', '<leader>gc', ':GoCoverage<CR>', bufopts)

-- Go-specific settings
vim.opt_local.expandtab = false
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
    -- Organize imports
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end,
})

-- Custom commands for Go
vim.api.nvim_create_user_command('GoImport', function()
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end, {})

vim.api.nvim_create_user_command('GoTest', function()
  vim.cmd('!go test ./...')
end, {})

vim.api.nvim_create_user_command('GoTestFunc', function()
  local func_name = vim.fn.search('func Test', 'bn')
  if func_name > 0 then
    local line = vim.fn.getline(func_name)
    local test_name = line:match('func (Test%w+)')
    if test_name then
      vim.cmd('!go test -run ' .. test_name)
    end
  end
end, {})

vim.api.nvim_create_user_command('GoCoverage', function()
  vim.cmd('!go test -cover ./...')
end, {})

-- Mason setup for managing LSP servers
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "jdtls", -- Java Language Server
    "gopls", -- Go Language Server
  },
})

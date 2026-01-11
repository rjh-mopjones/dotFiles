-- Mason setup for managing LSP servers
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    -- jdtls is configured manually in ftplugin/java.lua (not listed here to prevent auto-setup)
    "gopls", -- Go Language Server
  },
  handlers = {
    -- Default handler for all servers
    function(server_name)
      require("lspconfig")[server_name].setup({})
    end,
  },
})

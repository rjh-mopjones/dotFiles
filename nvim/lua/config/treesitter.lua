-- Treesitter configuration for syntax highlighting
require('nvim-treesitter.configs').setup({
  ensure_installed = { "java", "go", "gomod", "gosum", "lua", "vim", "vimdoc", "query", "json", "xml" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

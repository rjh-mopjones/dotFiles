-- Java-specific configuration with jdtls
local jdtls = require('jdtls')

-- Determine OS
local home = os.getenv('HOME')
local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local workspace_dir = home .. '/.local/share/nvim/jdtls-workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

-- Find java-debug and vscode-java-test paths
local bundles = {}
local java_debug_path = vim.fn.stdpath('data') .. '/lazy/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'
local java_debug_jar = vim.fn.glob(java_debug_path)
if java_debug_jar ~= '' then
  table.insert(bundles, java_debug_jar)
end

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', jdtls_path .. '/config_mac',
    '-data', workspace_dir,
  },

  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),

  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.Assert.*",
          "org.mockito.Mockito.*"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        useBlocks = true,
      },
      configuration = {
        runtimes = {
          -- Configure your Java runtimes here if you have multiple versions
          -- {
          --   name = "JavaSE-17",
          --   path = "/path/to/jdk-17",
          -- },
        }
      },
    }
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

    -- Java-specific commands
    vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, bufopts)
    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, bufopts)
    vim.keymap.set('v', '<leader>jv', [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]], bufopts)
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, bufopts)
    vim.keymap.set('v', '<leader>jc', [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], bufopts)
    vim.keymap.set('v', '<leader>jm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], bufopts)

    -- Java test commands
    vim.keymap.set('n', '<leader>jt', jdtls.test_nearest_method, bufopts)  -- lowercase t = current test
    vim.keymap.set('n', '<leader>jT', jdtls.test_class, bufopts)           -- uppercase T = all tests in class

    -- Setup DAP for Java
    jdtls.setup_dap({ hotcodereplace = 'auto' })
    require('jdtls.dap').setup_dap_main_class_configs()
  end,

  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

jdtls.start_or_attach(config)

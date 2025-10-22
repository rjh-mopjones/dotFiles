-- DAP (Debug Adapter Protocol) configuration
local dap = require('dap')
local dapui = require('dapui')

-- DAP UI setup
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25,
      position = "bottom",
    },
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = "single",
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
})

-- Virtual text setup
require("nvim-dap-virtual-text").setup()

-- Automatically open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- DAP signs
vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='🟡', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapLogPoint', {text='🔵', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='▶️', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointRejected', {text='❌', texthl='', linehl='', numhl=''})

-- Java DAP configuration (handled by jdtls in ftplugin/java.lua)
-- This is the configuration for remote debugging

-- Remote debugging configuration for Java
dap.configurations.java = dap.configurations.java or {}
table.insert(dap.configurations.java, {
  type = 'java',
  request = 'attach',
  name = "Debug (Attach) - Remote",
  hostName = "localhost",
  port = 5005,
})

-- Custom command to set remote debug host and port
vim.api.nvim_create_user_command('DapRemoteJava', function(opts)
  local args = vim.split(opts.args, " ")
  local host = args[1] or "localhost"
  local port = tonumber(args[2]) or 5005

  dap.configurations.java = dap.configurations.java or {}
  table.insert(dap.configurations.java, {
    type = 'java',
    request = 'attach',
    name = string.format("Debug (Attach) - Remote %s:%d", host, port),
    hostName = host,
    port = port,
  })

  print(string.format("Added remote debug configuration for %s:%d", host, port))
end, { nargs = '*' })

-- Key mappings for debugging
vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "DAP Continue" })
vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "DAP Step Over" })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "DAP Step Into" })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = "DAP Step Out" })
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Set Conditional Breakpoint" })
vim.keymap.set('n', '<leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = "Set Log Point" })
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = "Open REPL" })
vim.keymap.set('n', '<leader>dl', function() dap.run_last() end, { desc = "Run Last" })
vim.keymap.set('n', '<leader>dt', function() dapui.toggle() end, { desc = "Toggle DAP UI" })

-- Go debugging configuration with delve
local dap = require('dap')

-- Delve adapter configuration
dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'dlv',
    args = {'dap', '-l', '127.0.0.1:${port}'},
  }
}

-- Go debug configurations
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "delve",
    name = "Debug (Arguments)",
    request = "launch",
    program = "${file}",
    args = function()
      local args_string = vim.fn.input('Arguments: ')
      return vim.split(args_string, " +")
    end,
  },
  {
    type = "delve",
    name = "Debug Package",
    request = "launch",
    program = "${fileDirname}"
  },
  {
    type = "delve",
    name = "Debug Test",
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  {
    type = "delve",
    name = "Debug Test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  },
  {
    type = "delve",
    name = "Attach to Process",
    mode = "local",
    request = "attach",
    processId = require('dap.utils').pick_process,
  },
  {
    type = "delve",
    name = "Debug (Remote)",
    request = "attach",
    mode = "remote",
    remotePath = "${workspaceFolder}",
    port = 2345,
    host = "127.0.0.1",
    substitutePath = {
      {
        from = "${workspaceFolder}",
        to = function()
          return vim.fn.input('Remote path: ', vim.fn.getcwd(), 'file')
        end,
      },
    },
  },
}

-- Custom command for remote Go debugging with custom host and port
vim.api.nvim_create_user_command('DapRemoteGo', function(opts)
  local args = vim.split(opts.args, " ")
  local host = args[1] or "127.0.0.1"
  local port = tonumber(args[2]) or 2345

  -- Add or update remote debug configuration
  local found = false
  for i, config in ipairs(dap.configurations.go) do
    if config.name == string.format("Debug (Remote) - %s:%d", host, port) then
      dap.configurations.go[i] = {
        type = "delve",
        name = string.format("Debug (Remote) - %s:%d", host, port),
        request = "attach",
        mode = "remote",
        remotePath = "${workspaceFolder}",
        port = port,
        host = host,
        substitutePath = {
          {
            from = "${workspaceFolder}",
            to = function()
              return vim.fn.input('Remote path: ', vim.fn.getcwd(), 'file')
            end,
          },
        },
      }
      found = true
      break
    end
  end

  if not found then
    table.insert(dap.configurations.go, {
      type = "delve",
      name = string.format("Debug (Remote) - %s:%d", host, port),
      request = "attach",
      mode = "remote",
      remotePath = "${workspaceFolder}",
      port = port,
      host = host,
      substitutePath = {
        {
          from = "${workspaceFolder}",
          to = function()
            return vim.fn.input('Remote path: ', vim.fn.getcwd(), 'file')
          end,
        },
      },
    })
  end

  print(string.format("Added/Updated remote debug configuration for %s:%d", host, port))
end, { nargs = '*' })

-- Go-specific debugging keymaps
vim.keymap.set('n', '<leader>dgt', function()
  local test_name = vim.fn.search('func Test', 'bn')
  if test_name > 0 then
    local line = vim.fn.getline(test_name)
    local func_name = line:match('func (Test%w+)')
    if func_name then
      require('dap').run({
        type = "delve",
        name = "Debug Specific Test",
        request = "launch",
        mode = "test",
        program = "${file}",
        args = {"-test.run", "^" .. func_name .. "$"}
      })
    end
  end
end, { desc = "Debug Go Test (Current Function)" })

vim.keymap.set('n', '<leader>dgT', function()
  require('dap').run({
    type = "delve",
    name = "Debug Test (All)",
    request = "launch",
    mode = "test",
    program = "${file}"
  })
end, { desc = "Debug Go Test (All Tests)" })

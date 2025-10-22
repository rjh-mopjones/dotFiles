# Neovim Go Development Setup

A complete Neovim configuration for Go development with LSP, debugging (including remote debugging), and Gruvbox theme.

## Features

- **gopls (Go Language Server)**: Full LSP support with autocomplete, go-to-definition, refactoring
- **Delve Debugging**: Local and remote debugging with nvim-dap
- **Auto Format & Imports**: Automatically formats code and organizes imports on save
- **Gruvbox Theme**: Beautiful retro groove color scheme
- **File Explorer**: nvim-tree for file navigation
- **Fuzzy Finder**: Telescope for quick file/text search
- **Syntax Highlighting**: Treesitter for better syntax highlighting
- **Inlay Hints**: Parameter names, types, and more displayed inline

## Prerequisites

1. **Neovim** >= 0.9.0
   ```bash
   nvim --version
   ```

2. **Go** >= 1.21
   ```bash
   go version
   ```

3. **Delve** (Go debugger)
   ```bash
   go install github.com/go-delve/delve/cmd/dlv@latest
   ```
   Ensure `~/go/bin` is in your PATH:
   ```bash
   export PATH=$PATH:~/go/bin
   ```

4. **Git** (for plugin installation)
   ```bash
   git --version
   ```

5. **ripgrep** (for Telescope live grep)
   ```bash
   brew install ripgrep  # macOS
   ```

## Installation

1. **Backup your existing Neovim configuration** (if any):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Copy this configuration**:
   ```bash
   mkdir -p ~/.config/nvim
   cp -r /Users/roryhedderman/nvim/* ~/.config/nvim/
   ```

3. **Install plugins**: Open Neovim and wait for lazy.nvim to install all plugins:
   ```bash
   nvim
   ```

   The plugin manager will automatically install all required plugins on first launch.

4. **Install Mason packages**: After Neovim opens, Mason should automatically install gopls. If not, run:
   ```vim
   :Mason
   ```
   Then search for and install `gopls`.

5. **Verify Delve installation**:
   ```bash
   dlv version
   ```

## Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration entry point
├── ftplugin/
│   ├── java.lua               # Java-specific LSP configuration
│   └── go.lua                 # Go-specific LSP configuration
├── lua/
│   └── config/
│       ├── mason.lua          # LSP server manager
│       ├── completion.lua     # Autocomplete configuration
│       ├── treesitter.lua     # Syntax highlighting
│       ├── dap.lua           # Debugger configuration (Java)
│       ├── dap-go.lua        # Debugger configuration (Go)
│       ├── nvim-tree.lua     # File explorer
│       └── keymaps.lua       # Keybindings
├── README.md                  # Java setup guide
└── README-GO.md              # This file (Go setup guide)
```

## Key Mappings

### General
- `<Space>` - Leader key
- `<leader>w` - Save file
- `<leader>q` - Quit
- `<leader>h` - Clear search highlighting
- `<C-h/j/k/l>` - Navigate between windows
- `<S-h/l>` - Navigate between buffers

### File Navigation
- `<leader>e` - Toggle file explorer
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags

### LSP (in Go files)
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Find references
- `K` - Hover documentation
- `<C-k>` - Signature help
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format code (auto-runs on save)

### Go-specific
- `<leader>gi` - Organize imports (also auto-runs on save)
- `<leader>gt` - Run all tests
- `<leader>gT` - Run current test function
- `<leader>gc` - Show test coverage

### Debugging
- `<F5>` - Start/Continue debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out
- `<leader>b` - Toggle breakpoint
- `<leader>B` - Set conditional breakpoint
- `<leader>lp` - Set log point
- `<leader>dr` - Open debug REPL
- `<leader>dl` - Run last debug configuration
- `<leader>dt` - Toggle debug UI
- `<leader>dgt` - Debug current test file
- `<leader>dgT` - Debug current test function

## Go-Specific Features

### Auto Format and Organize Imports
The configuration automatically formats your Go code and organizes imports on save using `gofumpt` (stricter gofmt). No manual intervention needed!

### Inlay Hints
gopls provides inline hints for:
- Variable types
- Parameter names
- Constant values
- Function type parameters
- Composite literal fields and types

### Code Lenses
Interactive code actions appear above functions for:
- Running tests
- Generating code
- Managing dependencies
- Garbage collection details

### Static Analysis
Includes `staticcheck` integration for advanced static analysis.

## Debugging

### Local Debugging

1. Open a Go file
2. Set breakpoints with `<leader>b`
3. Press `<F5>` to start debugging
4. Select a debug configuration:
   - **Debug** - Debug current file
   - **Debug (Arguments)** - Debug with command-line arguments
   - **Debug Package** - Debug entire package
   - **Debug Test** - Debug tests in current file
   - **Debug Test (go.mod)** - Debug tests in current module

### Debugging Tests

**Debug current test file**:
- Press `<leader>dgt`

**Debug specific test function**:
- Place cursor in or near test function
- Press `<leader>dgT`

Or use `<F5>` and select "Debug Test" configuration.

### Remote Debugging

To debug a remote Go application:

1. **Start your Go application with Delve in headless mode**:
   ```bash
   dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient ./main.go
   ```

   Or attach to a running process:
   ```bash
   dlv attach <PID> --headless --listen=:2345 --api-version=2 --accept-multiclient
   ```

2. **In Neovim**, use the default remote configuration:
   - Press `<F5>`
   - Select "Debug (Remote)"
   - Enter the remote path when prompted (usually same as your workspace)
   - It will connect to `127.0.0.1:2345`

3. **For custom host/port**, use the command:
   ```vim
   :DapRemoteGo <host> <port>
   ```
   Example:
   ```vim
   :DapRemoteGo 192.168.1.100 2345
   ```
   Then press `<F5>` and select the newly created configuration.

### Common Remote Debugging Scenarios

**Docker Container**:
```dockerfile
# Dockerfile
FROM golang:1.21
RUN go install github.com/go-delve/delve/cmd/dlv@latest
COPY . /app
WORKDIR /app
EXPOSE 2345
CMD ["dlv", "debug", "--headless", "--listen=:2345", "--api-version=2", "--accept-multiclient", "./main.go"]
```

```bash
docker run -p 2345:2345 your-go-app
```

**Remote Server via SSH**:
```bash
# On remote server
dlv debug --headless --listen=0.0.0.0:2345 --api-version=2 --accept-multiclient ./main.go

# On local machine, create SSH tunnel
ssh -L 2345:localhost:2345 user@remote-server

# Then in Neovim, use default remote config (localhost:2345)
```

**Kubernetes Pod**:
```bash
# Forward port from pod
kubectl port-forward pod/your-pod 2345:2345

# Then in Neovim, use default remote config (localhost:2345)
```

**Attach to Running Process**:
```bash
# Find the process ID
ps aux | grep your-app

# Attach delve
dlv attach <PID> --headless --listen=:2345 --api-version=2 --accept-multiclient
```

## Custom Commands

The following custom commands are available in Go files:

- `:GoImport` - Organize imports manually
- `:GoTest` - Run all tests in the workspace
- `:GoTestFunc` - Run test function under cursor
- `:GoCoverage` - Show test coverage
- `:DapRemoteGo <host> <port>` - Add remote debug configuration

## gopls Configuration

The configuration includes advanced gopls settings:

### Static Analysis
- Unused parameters detection
- Shadow variable detection
- Nil value detection
- Unused write detection
- Type assertions

### Formatting
- Uses `gofumpt` (stricter than gofmt)
- Auto-organizes imports
- Removes unused imports

### Completion
- Fuzzy matching for symbols
- Complete unimported packages
- Placeholders for function parameters
- Static member suggestions

### Semantic Tokens
Enhanced syntax highlighting based on semantic information.

## Customization

### Change Theme Variant
Edit `init.lua`:
```lua
require("gruvbox").setup({
  contrast = "hard",  -- "soft", "medium", or "hard"
})
```

### Adjust gopls Settings
Modify the `settings.gopls` section in `ftplugin/go.lua` to customize Go LSP behavior.

### Disable Auto-format on Save
Comment out the `BufWritePre` autocmd in `ftplugin/go.lua`:
```lua
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.go",
--   callback = function()
--     ...
--   end,
-- })
```

### Change Tab Settings
Go conventionally uses tabs. To change this, modify `ftplugin/go.lua`:
```lua
vim.opt_local.expandtab = true  -- Use spaces instead of tabs
vim.opt_local.shiftwidth = 2    -- 2 spaces per indent
vim.opt_local.tabstop = 2       -- 2 spaces per tab
```

## Troubleshooting

### gopls not starting
- Check if gopls is installed: `:Mason`
- Verify Go is in your PATH: `which go`
- Check gopls is installed: `which gopls`
- Restart LSP: `:LspRestart`

### Debugger not working
- Ensure Delve is installed: `dlv version`
- Check if `~/go/bin` is in PATH: `echo $PATH`
- Install Delve: `go install github.com/go-delve/delve/cmd/dlv@latest`

### Remote debugging fails
- Verify Delve is listening: `lsof -i :2345` or `netstat -an | grep 2345`
- Check firewall rules on remote host
- Ensure port is exposed (Docker: `-p 2345:2345`)
- Use `--listen=0.0.0.0:2345` instead of `--listen=:2345` if connecting from different machine

### Imports not organizing
- Check LSP is running: `:LspInfo`
- Manually run: `<leader>gi` or `:GoImport`
- Restart LSP: `:LspRestart`

### Completion not working
- Restart LSP: `:LspRestart`
- Check LSP status: `:LspInfo`
- Ensure gopls is installed: `which gopls`

### Inlay hints not showing
Inlay hints are enabled by default in the configuration. If not visible:
- Check Neovim version (requires >= 0.10 for full support)
- Restart LSP: `:LspRestart`

## Go Module Support

This configuration works seamlessly with Go modules. Features include:
- Automatic workspace detection from `go.mod`
- Multi-module workspace support
- Dependency management through code lenses
- Auto-completion for module imports

## Testing Support

### Run Tests
- `:GoTest` - Run all tests
- `:GoTestFunc` - Run current test function
- `<leader>gt` - Run all tests
- `<leader>gT` - Run current test function

### Debug Tests
- `<leader>dgt` - Debug current test file
- `<leader>dgT` - Debug current test function
- Use `<F5>` and select "Debug Test" configuration

### Coverage
- `:GoCoverage` - Show test coverage
- `<leader>gc` - Show test coverage

## Additional Resources

- [gopls documentation](https://github.com/golang/tools/tree/master/gopls)
- [Delve documentation](https://github.com/go-delve/delve)
- [nvim-dap documentation](https://github.com/mfussenegger/nvim-dap)
- [Gruvbox theme](https://github.com/ellisonleao/gruvbox.nvim)

## License

This configuration is free to use and modify as needed.

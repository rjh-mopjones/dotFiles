# Neovim Java Development Setup

A complete Neovim configuration for Java development with LSP, debugging (including remote debugging), and Gruvbox theme.

## Features

- **Java Language Server (jdtls)**: Full LSP support with autocomplete, go-to-definition, refactoring
- **Debugging**: Local and remote debugging with nvim-dap
- **Gruvbox Theme**: Beautiful retro groove color scheme
- **File Explorer**: nvim-tree for file navigation
- **Fuzzy Finder**: Telescope for quick file/text search
- **Syntax Highlighting**: Treesitter for better syntax highlighting

## Prerequisites

1. **Neovim** >= 0.9.0
   ```bash
   nvim --version
   ```

2. **Java Development Kit (JDK)** >= 17
   ```bash
   java -version
   ```

3. **Git** (for plugin installation)
   ```bash
   git --version
   ```

4. **ripgrep** (for Telescope live grep)
   ```bash
   brew install ripgrep  # macOS
   ```

5. **Node.js** (optional, for some LSP features)
   ```bash
   node --version
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

4. **Install Mason packages**: After Neovim opens, Mason should automatically install jdtls. If not, run:
   ```vim
   :Mason
   ```
   Then search for and install `jdtls`.

5. **Build java-debug**: The java-debug plugin needs to be built:
   ```bash
   cd ~/.local/share/nvim/lazy/java-debug
   ./mvnw clean install
   ```

## Configuration Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration entry point
├── ftplugin/
│   └── java.lua               # Java-specific LSP configuration
├── lua/
│   └── config/
│       ├── mason.lua          # LSP server manager
│       ├── completion.lua     # Autocomplete configuration
│       ├── treesitter.lua     # Syntax highlighting
│       ├── dap.lua           # Debugger configuration
│       ├── nvim-tree.lua     # File explorer
│       └── keymaps.lua       # Keybindings
└── README.md
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

### LSP (in Java files)
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Find references
- `K` - Hover documentation
- `<C-k>` - Signature help
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format code

### Java-specific
- `<leader>jo` - Organize imports
- `<leader>jv` - Extract variable
- `<leader>jc` - Extract constant
- `<leader>jm` - Extract method (visual mode)

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

## Debugging

### Local Debugging

1. Open a Java file
2. Set breakpoints with `<leader>b`
3. Press `<F5>` to start debugging
4. Select a debug configuration (e.g., "Debug (Launch) - Main")

### Remote Debugging

To debug a remote Java application:

1. **Start your Java application with debug flags**:
   ```bash
   java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar your-app.jar
   ```

2. **In Neovim**, use the default remote configuration:
   - Press `<F5>`
   - Select "Debug (Attach) - Remote"
   - It will connect to `localhost:5005`

3. **For custom host/port**, use the command:
   ```vim
   :DapRemoteJava <host> <port>
   ```
   Example:
   ```vim
   :DapRemoteJava 192.168.1.100 5005
   ```
   Then press `<F5>` and select the newly created configuration.

### Common Remote Debugging Scenarios

**Docker Container**:
```bash
docker run -p 5005:5005 -e JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" your-image
```

**Spring Boot**:
```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar spring-boot-app.jar
```

**Gradle**:
```bash
./gradlew bootRun --debug-jvm
```

**Maven**:
```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
```

## Customization

### Change Theme Variant
Edit `init.lua`:
```lua
require("gruvbox").setup({
  contrast = "hard",  -- "soft", "medium", or "hard"
})
```

### Configure Java Runtime
Edit `ftplugin/java.lua` to add your Java installations:
```lua
configuration = {
  runtimes = {
    {
      name = "JavaSE-17",
      path = "/path/to/jdk-17",
    },
    {
      name = "JavaSE-21",
      path = "/path/to/jdk-21",
    },
  }
}
```

### Adjust LSP Settings
Modify the `settings.java` section in `ftplugin/java.lua` to customize Java LSP behavior.

## Troubleshooting

### jdtls not starting
- Check if jdtls is installed: `:Mason`
- Verify Java is in your PATH: `which java`
- Check the config path in `ftplugin/java.lua` (should be `config_mac` for macOS, `config_linux` for Linux, or `config_win` for Windows)

### Debugger not working
- Ensure java-debug is built: `cd ~/.local/share/nvim/lazy/java-debug && ./mvnw clean install`
- Check if bundles are loaded in `ftplugin/java.lua`

### Remote debugging fails
- Verify the remote application is listening: `netstat -an | grep 5005`
- Check firewall rules
- Ensure the port is exposed (Docker: `-p 5005:5005`)

### Completion not working
- Restart LSP: `:LspRestart`
- Check LSP status: `:LspInfo`

## Additional Resources

- [nvim-jdtls documentation](https://github.com/mfussenegger/nvim-jdtls)
- [nvim-dap documentation](https://github.com/mfussenegger/nvim-dap)
- [Gruvbox theme](https://github.com/ellisonleao/gruvbox.nvim)

## License

This configuration is free to use and modify as needed.

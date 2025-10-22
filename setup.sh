#!/usr/bin/env bash

set -e  # Exit on error

echo "🚀 Starting dotfiles setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${GREEN}Using dotfiles from: ${SCRIPT_DIR}${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}✓ Homebrew already installed${NC}"
fi

# Update Homebrew
echo -e "${YELLOW}Updating Homebrew...${NC}"
brew update

# Install core tools
echo -e "${YELLOW}Installing core tools...${NC}"
tools=(
    "neovim"
    "tmux"
    "starship"
    "git"
    "ripgrep"      # For Telescope in neovim
    "node"         # For LSP servers
    "go"           # For Go development
    "openjdk"      # For Java development
    "maven"        # For Java debug adapter
    "fd"           # Better find alternative
    "fzf"          # Fuzzy finder
)

for tool in "${tools[@]}"; do
    if brew list "$tool" &>/dev/null; then
        echo -e "${GREEN}✓ $tool already installed${NC}"
    else
        echo -e "${YELLOW}Installing $tool...${NC}"
        brew install "$tool"
    fi
done

# Set up Java environment
echo -e "${YELLOW}Setting up Java environment...${NC}"
if ! grep -q "JAVA_HOME" ~/.zshrc 2>/dev/null; then
    echo 'export JAVA_HOME=$(/usr/libexec/java_home)' >> ~/.zshrc
fi

# Create symlinks
echo -e "${YELLOW}Creating symlinks...${NC}"

# Backup existing configs
backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Neovim
if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo -e "${YELLOW}Backing up existing neovim config...${NC}"
    mv "$HOME/.config/nvim" "$backup_dir/"
fi
if [ -L "$HOME/.config/nvim" ]; then
    rm "$HOME/.config/nvim"
fi
ln -sf "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
echo -e "${GREEN}✓ Linked neovim config${NC}"

# Starship
if [ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    echo -e "${YELLOW}Backing up existing starship config...${NC}"
    mv "$HOME/.config/starship.toml" "$backup_dir/"
fi
if [ -L "$HOME/.config/starship.toml" ]; then
    rm "$HOME/.config/starship.toml"
fi
ln -sf "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"
echo -e "${GREEN}✓ Linked starship config${NC}"

# Tmux
if [ -e "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    echo -e "${YELLOW}Backing up existing tmux config...${NC}"
    mv "$HOME/.tmux.conf" "$backup_dir/"
fi
if [ -L "$HOME/.tmux.conf" ]; then
    rm "$HOME/.tmux.conf"
fi
ln -sf "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
echo -e "${GREEN}✓ Linked tmux config${NC}"

# Initialize Starship in shell config if not already present
echo -e "${YELLOW}Configuring Starship prompt...${NC}"
if ! grep -q "starship init" ~/.zshrc 2>/dev/null; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    echo -e "${GREEN}✓ Added Starship to .zshrc${NC}"
else
    echo -e "${GREEN}✓ Starship already configured in .zshrc${NC}"
fi

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${YELLOW}Installing Tmux Plugin Manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo -e "${GREEN}✓ Installed TPM${NC}"
    echo -e "${YELLOW}Note: Press 'prefix + I' in tmux to install plugins${NC}"
else
    echo -e "${GREEN}✓ TPM already installed${NC}"
fi

# Install Neovim plugins
echo -e "${YELLOW}Installing Neovim plugins...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                        ║${NC}"
echo -e "${GREEN}║   ✓ Setup completed successfully!     ║${NC}"
echo -e "${GREEN}║                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Open tmux and press 'prefix + I' to install tmux plugins"
echo "  3. Open neovim and run ':checkhealth' to verify setup"
echo ""
if [ -d "$backup_dir" ] && [ "$(ls -A $backup_dir)" ]; then
    echo -e "${YELLOW}Your old configs were backed up to: ${backup_dir}${NC}"
fi


autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}%% >: "

# Added by Toolbox App
export PATH="$PATH:/Users/roryhedderman/Library/Application Support/JetBrains/Toolbox/scripts"


eval "$(/opt/homebrew/bin/brew shellenv)"

export RUST_BACKTRACE=1

# Source secrets file (not committed to git)
if [ -f ~/term_prof/zsh/.zsh_secrets ]; then
    source ~/term_prof/zsh/.zsh_secrets
fi


# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'
export GOROOT='/usr/local/go'
export GOHOME='/Users/roryhedderman/go'
export JAVA_HOME=/Users/roryhedderman/Library/Java/JavaVirtualMachines/corretto-17.0.9/Contents/Home

# Tell ls to be colourful
export LSCOLORS=Exfxcxdxbxegedabagacad
export CLICOLOR=1
alias ls="ls -aG"
alias prw="open /Applications/Prowlarr.app"
alias c="clear"
alias pg="ping 8.8.8.8"
alias gc="git clone"
alias ll="ls -alG"
alias obs="cd /Users/roryhedderman/Library/Mobile\ Documents/iCloud~md~obsidian"
alias cpp="cd /Users/roryhedderman/Documents/IdeaProjects/Cpp"
alias jv="cd /Users/roryhedderman/Documents/IdeaProjects/Java"
alias js="cd /Users/roryhedderman/Documents/IdeaProjects/JavaScript"
alias rust="cd /Users/roryhedderman/Documents/IdeaProjects/Rust"
alias godot="cd /Users/roryhedderman/Documents/GodotProjects"
alias golang="cd /Users/roryhedderman/GolandProjects/"
alias dgg="docker rm $(docker ps -a -q) && docker rmi $(docker images -a -q)"
alias dcu="docker-compose up "
alias nv="nvim"
alias tm="tmux"



alias eterm="nv ~/term_prof"
alias rprof="source ~/.zshrc"
alias rterm='source ~/.zshrc && tmux source-file ~/.tmux.conf 2>/dev/null && echo "✓ Reloaded: zsh, tmux, starship" && echo "ℹ Neovim: restart or use :source $MYVIMRC from within nvim"'
alias tradle-time="python3 /Users/roryhedderman/Documents/IdeaProjects/Python/tradle/get_tradle.py"
alias greset="git reset --hard origin/main"
alias aseprite=" /Users/roryhedderman/Library/Application\ Support/Steam/steamapps/common/Aseprite/Aseprite.app/Contents/MacOS/aseprite"


dg(){
docker rm $(docker ps -a -q) && docker rmi $(docker images -a -q)
}
dmerk(){
docker system prune -a && dg

}
export PATH=$PATH:~/go/bin

# History configuration
HISTFILE=~/term_prof/zsh/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# Prefix-based history search with up/down arrows
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# Autocompletion configuration
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive completion

# Enable zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable zsh-syntax-highlighting (must be at the end)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable starship from setting window title (breaks tmux window names)
export STARSHIP_SET_WINDOW_TITLE=false
eval "$(starship init zsh)"

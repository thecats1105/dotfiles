set CONFIG_FILE ~/.config/fish/config.fish

set fish_greeting ""

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# linuxbrew env
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# bin
set -gx PATH ~/.bin $PATH

# aliases
alias c clear
alias cd z
alias bat "prettybat --paging=never --style=plain"
alias less "prettybat --paging=never"
alias ls "eza --group-directories-first --no-user --icons auto"
alias la "ls -a"
alias l "ls -l"
alias ll "l -a"
alias grep rg
alias g git
# java version manager
function jvm
    sudo update-alternatives --config java
    set JAVA_HOME (readlink -nf $(which java) | xargs dirname | xargs dirname )
    if ! test -e $JAVA_HOME
        set -e JAVA_HOME
    end
    set -gx JAVA_HOME $JAVA_HOME
end
alias fnmd "fnm use default"
alias fnmu "fnm use"
alias fnml "fnm use latest"
alias pip pip3
alias py python3
alias python python3
alias tasklist "ps -ef"
alias tl tasklist
alias lg lazygit
# yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
alias e y
# neovim
alias vim nvim
alias vi nvim
# WSL
# open vscode in shell
alias code "$(wslpath $(wslvar LOCALAPPDATA))/Programs/Microsoft\ VS\ Code/bin/code"
alias fc file2clip.exe
alias fastfetchw fastfetch.exe
alias ghqw ghq.exe
alias trashw trash.exe

set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH
set -gx PATH ~/.node_modules/bin $PATH
alias npm ~/.node_modules/bin/npm
set WIN "--platform=win32"

# fnm
fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell fish | source
if test (fnm current) = none
    fnm use default
end

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

# Java
if ! set -q JAVA_HOME
    set JAVA_HOME (readlink -nf $(which java) | xargs dirname | xargs dirname )
    if ! test -e $JAVA_HOME
        set -e JAVA_HOME
    end
    set -gx JAVA_HOME $JAVA_HOME
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
    source $LOCAL_CONFIG
end

# Environment variables
set -gx GHQ $HOME/ghq
set -gx ghq $GHQ
set -gx LESS '-q --mouse'

# cdhost
_cdhost_init $CONFIG_FILE

# argc-completions
set -gx ARGC_COMPLETIONS_ROOT "$HOME/.config/fish/argc-completions"
set -gx ARGC_COMPLETIONS_PATH "$ARGC_COMPLETIONS_ROOT/completions/linux:$ARGC_COMPLETIONS_ROOT/completions"
fish_add_path "$ARGC_COMPLETIONS_ROOT/bin"
# To add completions for only the specified command, modify next line e.g. set argc_scripts cargo git
set argc_scripts (command ls -p -1 "$ARGC_COMPLETIONS_ROOT/completions/linux" "$ARGC_COMPLETIONS_ROOT/completions" | sed -n 's/\.sh$//p')
argc --argc-completions fish $argc_scripts | source

# Set tldr Language
function tldr
    set LANG ko_KR.UTF-8
    command tldr $argv
end

# starship
function starship_transient_prompt_func
    starship module character
end
starship init fish | source
enable_transience

# Windows Terminal
function __storePathForWindowsTerminal --on-variable PWD
    if test -n "$WT_SESSION"
        printf "\e]9;9;%s\e\\" (wslpath -w "$PWD")
    end
end

__storePathForWindowsTerminal

alias wt "wt.exe"

# zoxide
zoxide init fish | source

# none-blinking filled box cursor
echo -ne "\e[2 q"

# czg
alias czg="NODE_OPTIONS='--experimental-transform-types --disable-warning ExperimentalWarning' command czg"

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# bun
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PATH $BUN_INSTALL/bin $PATH

# eslint
# set -gx ESLINT_USE_FLAT_CONFIG false
set -gx GOOGLE_CLOUD_PROJECT gen-lang-client-0319877833

# load secrets from .env
if test -f ~/.env
    loadenv ~/.env
end

# https://github.com/badrisnarayanan/antigravity-claude-proxy
alias acc "PORT=8045 command acc"

# https://github.com/sujitagarwal/multigravity-cli
alias antigravity agy

# OpenClaw Completion
source "/home/thecats1105/.openclaw/completions/openclaw.fish"

# trashy
trash completions fish | source


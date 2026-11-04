# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# config file environment
$CONFIG_FILE = Join-Path $HOME .config/powershell/user_profile.ps1

# Environment
$Env:GOOGLE_CLOUD_PROJECT = 'gen-lang-client-0319877833'

# Settings
$Env:CC = 'gcc'
$Env:LESS = '-Q'
$Env:PATH = (Join-Path $HOME .local/bin) + [IO.Path]::PathSeparator + $Env:PATH
$Env:pathext = $Env:pathext + [IO.Path]::PathSeparator +".PY"
$Env:SHELL = 'pwsh.exe'

# PowerShell Modules
Import-Module PSFzf && (
  Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
)

Import-Module PSScriptAnalyzer && (
  Set-Alias -Name 'psprettier' -Value 'Invoke-Formatter'
)

Import-Module PSEverything
Import-Module PowerTree

# fnm
fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell powershell | Out-String | Invoke-Expression
$Env:Path = "$Env:USERPROFILE\.node_modules" + [IO.Path]::PathSeparator + $Env:Path

# bun
$Env:Path = "$Env:USERPROFILE\.bun\bin" + [IO.Path]::PathSeparator + $Env:Path

# Alias
Set-Alias -Name 'c' -Value 'clear'
Set-Alias -Name 'vim' -Value 'nvim'
Set-Alias -Name 'g' -Value 'git'
Set-Alias -Name 'grep' -Value 'rg'
Set-Alias -Name 'lg' -Value 'lazygit'
Set-Alias -Name 'nvm' -Value 'fnm'
Set-Alias -Name 'curl' -Value 'C:/ProgramData/scoop/shims/curl.exe'
Set-Alias -Name 'tig' -Value 'C:/ProgramData/scoop/shims/tig.exe'
Set-Alias -Name 'pkill' -Value 'Invoke-FuzzyKillProcess'
Set-Alias -Name 'tasklist' -Value 'Get-Process'
Set-Alias -Name 'tl' -Value 'Get-Process'

# Functions
# which command
function which ($command)
{
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# czg
function czg
{
  param($Arguments)
  $originalNodeOptions = $Env:NODE_OPTIONS
  $env:NODE_OPTIONS = '--experimental-transform-types --disable-warning ExperimentalWarning'
  & czg $Arguments
  $env:NODE_OPTIONS = $originalNodeOptions
}

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Run Scripts
Get-ChildItem -ErrorAction Ignore -Path (Join-Path $HOME .config/powershell/scripts) -Filter *.ps1 | ForEach-Object {
  & $_.FullName
}

# Oh-My-Opencode: non-interactive-env
$Env:CI = 'true'
$Env:DEBIAN_FRONTEND = 'noninteractive'
$Env:GIT_TERMINAL_PROMPT = '0'
$Env:GCM_INTERACTIVE = 'never'
$Env:HOMEBREW_NO_AUTO_UPDATE = '1'
# Block interactive editors
$Env:GIT_EDITOR = ':'
$Env:EDITOR = ':'
$Env:VISUAL = ''
$Env:GIT_SEQUENCE_EDITOR = ':'
$Env:GIT_MERGE_AUTOEDIT = 'no'
# Block pagers
$Env:GIT_PAGER = 'cat'
$Env:PAGER = 'cat'
# NPM non-interactive
$Env:npm_config_yes = 'true'
# Pip non-interactive
$Env:PIP_NO_INPUT = '1'
# Yarn non-interactive
$Env:YARN_ENABLE_IMMUTABLE_INSTALLS = 'false'

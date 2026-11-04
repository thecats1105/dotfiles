# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# config file environment
$CONFIG_FILE = Join-Path $HOME .config/powershell/user_profile.ps1

# none-blinking filled box cursor
[Console]::Write("`e[2 q")

# Environment
$Env:GOOGLE_CLOUD_PROJECT = 'gen-lang-client-0319877833'

# Settings
$Env:CC = 'gcc'
$Env:LESS = '-Q'
$Env:PATH = (Join-Path $HOME .local/bin) + [IO.Path]::PathSeparator + (Join-Path $HOME bin) + [IO.Path]::PathSeparator + $Env:PATH
$Env:pathext = $Env:pathext + [IO.Path]::PathSeparator +".PY"
$Env:SHELL = 'pwsh.exe'

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
if ($Host.UI.SupportsVirtualTerminal && ![Console]::IsOutputRedirected && !$Env:OPENCODE)
{
  try
  {
    Set-PSReadLineOption -PredictionSource History -ErrorAction Ignore
  } catch
  {
  }
}
Set-PSReadLineKeyHandler -Key 'Ctrl+d' -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key 'Ctrl+l' -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key 'Alt+l' -Function AcceptNextSuggestionWord

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
Remove-Item -ErrorAction Ignore alias:cd
Set-Alias -Name 'cd' -Value 'z'
Set-Alias -Name 'vim' -Value 'nvim'
function nvim
{
  & (Get-Command nvim.exe -ErrorAction SilentlyContinue).Source $args
  [Console]::Write("`e[2 q")
}
Set-Alias -Name 'g' -Value 'git'
Set-Alias -Name 'grep' -Value 'rg'
Remove-Item -ErrorAction Ignore alias:ls
function ls
{ eza --group-directories-first --no-user --icons auto $args
}
function la
{ eza -a --group-directories-first --no-user --icons auto $args
}
function l
{ eza -l --group-directories-first --no-user --icons auto $args
}
function ll
{ eza -al --group-directories-first --no-user --icons auto $args
}
Set-Alias -Name 'lg' -Value 'lazygit'
Set-Alias -Name 'nvm' -Value 'fnm'
Set-Alias -Name 'curl' -Value (Join-Path $env:USERPROFILE 'scoop/shims/curl.exe')
Set-Alias -Name 'tig' -Value 'C:/Program Files/Git/usr/bin/tig.exe'
Set-Alias -Name 'pkill' -Value 'Invoke-FuzzyKillProcess'
Set-Alias -Name 'tasklist' -Value 'Get-Process'
Set-Alias -Name 'tl' -Value 'Get-Process'
function cat
{ bat --paging=never --style=plain $args
}
function less
{ bat --paging=never $args
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

# Completions
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# argc-completions
$Env:ARGC_COMPLETIONS_ROOT = Join-Path $HOME .config/powershell/argc-completions
$Env:ARGC_COMPLETIONS_PATH =
(
  (Join-Path $Env:ARGC_COMPLETIONS_ROOT completions/windows) + [IO.Path]::PathSeparator +
  (Join-Path $Env:ARGC_COMPLETIONS_ROOT completions)
)
$Env:PATH = (Join-Path $Env:ARGC_COMPLETIONS_ROOT bin) + [IO.Path]::PathSeparator + $Env:PATH
# To add completions for only the specified command, modify next line e.g. $argc_scripts = @("cargo", "git")
$argc_scripts = ((Get-ChildItem -File -Path (Join-Path $Env:ARGC_COMPLETIONS_ROOT completions/windows), (Join-Path $Env:ARGC_COMPLETIONS_ROOT completions)) | ForEach-Object { $_.BaseName })
argc --argc-completions powershell $argc_scripts | Out-String | Invoke-Expression

# starship
function Invoke-Starship-TransientFunction
{
  &starship module character
}
function Invoke-Starship-PreCommand
{
  $loc = $executionContext.SessionState.Path.CurrentLocation;
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq "FileSystem")
  {
    $providerPath = $loc.ProviderPath
    $prompt += "$([char]27)]9;9;`"$($providerPath)`"$([char]27)\"
  }
  $host.ui.Write($prompt)
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Run Scripts
Get-ChildItem -ErrorAction Ignore -Path (Join-Path $HOME .config/powershell/scripts) -Filter *.ps1 | ForEach-Object {
  & $_.FullName
}

# multigravity-cli
Invoke-Expression (& multigravity completion powershell)

# Startup messages
if ($Host.UI.SupportsVirtualTerminal -eq $false)
{
  if (Get-WinSystemLocale -eq "ko-KR")
  {
    Write-Warning "현재 콘솔 환경은 가상 터미널을 지원하지 않아 예측 제안 기능을 사용할 수 없습니다."
  } else
  {
    Write-Warning "The current console environment does not support virtual terminal, so the prediction suggestion feature cannot be used."
  }
}

function global:Invoke-FzfCd
{
  $paths = New-Object System.Collections.Generic.List[string]

  $paths.Add("$HOME\.config")

  if (Get-Command ghq -ErrorAction SilentlyContinue)
  {
    Get-ChildItem -Path (ghq root) -Depth 4 -Directory -Filter ".git" -Force -ErrorAction SilentlyContinue |
      ForEach-Object { $paths.Add($_.Parent.FullName) }
  }

  Get-ChildItem -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne ".git" } |
    ForEach-Object { $paths.Add($_.FullName) }

  $selected = $paths | Select-Object -Unique | fzf

  if ($selected)
  {
    Set-Location $selected
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+f' {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  Invoke-FzfCd
}

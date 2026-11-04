# Load functions
$funcDir = Join-Path $env:USERPROFILE '.config\powershell\functions'
if (Test-Path $funcDir)
{
  Get-ChildItem -Path $funcDir -Filter *.ps1 | ForEach-Object {
    $fileName = $_.BaseName
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$errors)

    $func = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $fileName }, $true)

    if ($func)
    {
      . $_.FullName
    }
  }
}

if (!$Env:OPENCODE)
{
  . (Join-Path $env:USERPROFILE '.config\powershell\user_profile.ps1' -ErrorAction SilentlyContinue)
} else
{
  . (Join-Path $env:USERPROFILE '.config\powershell\opencode_profile.ps1' -ErrorAction SilentlyContinue)
}

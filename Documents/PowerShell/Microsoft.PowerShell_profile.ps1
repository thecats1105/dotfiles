$CONFIG_PATH = Join-Path $env:USERPROFILE '.config/powershell/config.ps1'

if ( Test-Path $CONFIG_PATH )
{
  . $CONFIG_PATH
}

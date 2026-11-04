function Global:Enable-Venv
{
  if ($script = Get-Item -ErrorAction Ignore -LiteralPath ./venv/Scripts/activate.ps1)
  {
    & $script
  } elseif ($script = Get-Item -ErrorAction Ignore -LiteralPath ./.venv/Scripts/activate.ps1)
  {
    & $script
  }
}

$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction =
[Delegate]::Combine(
  $ExecutionContext.SessionState.InvokeCommand.LocationChangedAction,
  [EventHandler[System.Management.Automation.LocationChangedEventArgs]] {
    Enable-Venv
  }
)

Enable-Venv

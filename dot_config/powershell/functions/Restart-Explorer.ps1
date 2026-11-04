function Restart-Explorer
{
  Stop-Process -Name 'explorer'
  yasbc.exe reload
}

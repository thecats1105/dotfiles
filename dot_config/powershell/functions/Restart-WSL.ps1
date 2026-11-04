function Restart-WSL
{
  wsl --shutdown
  wsl --exec dbus-launch true
}

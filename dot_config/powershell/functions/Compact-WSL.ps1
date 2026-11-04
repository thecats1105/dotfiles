function Compact-WSL
{
  [CmdletBinding()]
  param (
    [string]$VhdPath = "C:\WSL\Ubuntu-24.04\ext4.vhdx"
  )

  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (!$isAdmin)
  {
    Write-Warning "Optimize-VHD를 실행하려면 관리자 권한이 필요합니다. 관리자 권한 PowerShell에서 실행해 주세요."
    return
  }

  if (!(Test-Path $VhdPath))
  {
    Write-Error "VHDX 파일을 찾을 수 없습니다: $VhdPath"
    return
  }

  Write-Host "1. WSL 종료 중..." -ForegroundColor Cyan
  wsl.exe --shutdown

  $before = (Get-Item $VhdPath).Length
  $beforeGb = [math]::Round($before / 1GB, 2)
  Write-Host "2. VHDX 정밀 압축 진행 중 (Optimize-VHD -Mode Full)..." -ForegroundColor Cyan
  Write-Host "   대상: $VhdPath (현재 크기: $beforeGb GB)" -ForegroundColor Gray

  Optimize-VHD -Path $VhdPath -Mode Full

  $after = (Get-Item $VhdPath).Length
  $afterGb = [math]::Round($after / 1GB, 2)
  $freedGb = [math]::Round(($before - $after) / 1GB, 2)

  Write-Host "`n압축 완료!" -ForegroundColor Green
  Write-Host "용량 변화: $beforeGb GB -> $afterGb GB ($freedGb GB 확보됨)" -ForegroundColor Green
}

function _update
{
  scoop update -a && scoop cleanup -a
  scoop cache rm -a

  # fnm (Node.js version manager)
  $fnmConfig = Join-Path $env:USERPROFILE ".node-versions"
  if (Test-Path $fnmConfig)
  {
    Write-Host "==> [fnm] Updating Node.js versions from ~/.node-versions..." -ForegroundColor Cyan

    $fnmDir = $env:FNM_DIR
    if (-not $fnmDir)
    {
      $fnmDir = Join-Path $env:APPDATA "fnm"
    }
    $nodeVersionsDir = Join-Path $fnmDir "node-versions"

    $keepVersions = [System.Collections.Generic.List[string]]::new()
    $defaultVersion = $null
    $fallbackDefault = $null

    foreach ($rawLine in (Get-Content $fnmConfig))
    {
      $cleanLine = ($rawLine -replace '#.*', '').Trim()
      if ([string]::IsNullOrWhiteSpace($cleanLine))
      {
        continue
      }

      $isDefault = $false
      if ($cleanLine -match '\bdefault\b')
      {
        $isDefault = $true
        $cleanLine = ($cleanLine -replace '\bdefault\b', '').Trim()
      }

      $targetLabel = $cleanLine
      if ($isDefault) { $targetLabel += " (default)" }
      Write-Host "  -> Resolving $targetLabel..." -ForegroundColor Blue

      $installedVer = $null
      $installOutput = ""

      switch -Wildcard ($cleanLine)
      {
        "lts-latest" {
          $installOutput = & fnm install --lts 2>&1 | Out-String
          if ($installOutput -match 'Installing Node (v\S+)')
          {
            $installedVer = $Matches[1]
            & fnm alias $installedVer lts-latest 2>&1 | Out-Null
          }
        }
        "lts" {
          $installOutput = & fnm install --lts 2>&1 | Out-String
          if ($installOutput -match 'Installing Node (v\S+)')
          {
            $installedVer = $Matches[1]
            & fnm alias $installedVer lts-latest 2>&1 | Out-Null
          }
        }
        "latest" {
          $installOutput = & fnm install --latest 2>&1 | Out-String
          if ($installOutput -match 'Installing Node (v\S+)')
          {
            $installedVer = $Matches[1]
            & fnm alias $installedVer latest 2>&1 | Out-Null
          }
        }
        default {
          $installOutput = & fnm install $cleanLine 2>&1 | Out-String
          if ($installOutput -match 'Installing Node (v\S+)')
          {
            $installedVer = $Matches[1]
          }
        }
      }

      if ($installedVer)
      {
        $keepVersions.Add($installedVer)
        if ($installOutput -match 'Version already installed')
        {
          Write-Host "     $installedVer is already up to date" -ForegroundColor Green
        }
        else
        {
          Write-Host "     Installed/Updated $installedVer" -ForegroundColor Green
        }

        if ($isDefault)
        {
          $defaultVersion = $installedVer
        }
        if ($cleanLine -in @("lts-latest", "lts") -and -not $fallbackDefault)
        {
          $fallbackDefault = $installedVer
        }
      }
      else
      {
        Write-Host "     Failed to install: $cleanLine" -ForegroundColor Red
      }
    }

    if ($keepVersions.Count -gt 0 -and (Test-Path $nodeVersionsDir))
    {
      $installedVersions = Get-ChildItem -Path $nodeVersionsDir -Directory | Where-Object { $_.Name -notmatch '^\.' }
      foreach ($dir in $installedVersions)
      {
        if ($dir.Name -notin $keepVersions)
        {
          Write-Host "  -> Removing old Node version: $($dir.Name)..." -ForegroundColor Yellow
          & fnm uninstall $dir.Name 2>&1 | Out-Null
        }
      }
    }

    if (-not $defaultVersion)
    {
      if ($fallbackDefault)
      {
        $defaultVersion = $fallbackDefault
      }
      elseif ($keepVersions.Count -gt 0)
      {
        $defaultVersion = $keepVersions[0]
      }
    }

    if ($defaultVersion)
    {
      & fnm default $defaultVersion 2>&1 | Out-Null
      & fnm use default 2>&1 | Out-Null
      Write-Host "  -> Default Node set to $defaultVersion" -ForegroundColor Magenta
    }

    $activeVer = (& node -v 2>&1 | Out-String).Trim()
    Write-Host "==> [fnm] Done. Current active version: $activeVer" -ForegroundColor Cyan
  }

  npm update -g
  bun $PSScriptRoot\..\scripts\update-bun-global.mjs
  store updates --apply
  winget upgrade

  # Clean caches
  npm cache clean --force
  bun pm cache rm -g
  pnpm store prune
}


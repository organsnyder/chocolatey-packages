$options = @{
  tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
}

$packageParameters = @{
  packageName = 'SSCERuntime-ENU';
  fileFullPath = Join-Path $options['tempDir'] "SSCERuntime-ENUInstall.exe";
  url = 'http://download.microsoft.com/download/E/C/1/EC1B2340-67A0-4B87-85F0-74D987A27160/SSCERuntime-ENU.exe';
  url64bit = 'http://download.microsoft.com/download/E/C/1/EC1B2340-67A0-4B87-85F0-74D987A27160/SSCERuntime-ENU.exe';
  checksum = '2B15E1FAB3533E9C3807184B741A24B4A66C24664432BF6B6177FEFBD1BCE6E3';
  checksumType = 'Sha256';
  checksum64 = '2B15E1FAB3533E9C3807184B741A24B4A66C24664432BF6B6177FEFBD1BCE6E3';
  checksumType64 = 'Sha256';
}

try {
  if (![System.IO.Directory]::Exists($options['tempDir'])) { [System.IO.Directory]::CreateDirectory($options['tempDir']) | Out-Null }

  Get-ChocolateyWebFile @packageParameters

  Start-Process "$($packageParameters['fileFullPath'])" -ArgumentList @("/T:`"$($options['tempDir'])`"", "/q") -Wait

  try {
    Install-ChocolateyPackage 'mssqlserver-compact3.5-x32' 'msi' '/quiet /passive' (Join-Path $options['tempDir'] 'SSCERuntime_x86-ENU.msi') ''
  }
  catch {
    #Try to handle a partially installed condition where x86 is installed but x64 isn't.
    if ($LASTEXITCODE -ne 1603) { throw $_ }
  }

  if (Get-ProcessorBits -eq 64) {
      Install-ChocolateyPackage 'mssqlserver-compact3.5-x64' 'msi' '/quiet /passive' '' (Join-Path $options['tempDir'] 'SSCERuntime_x64-ENU.msi')
  }
}
Finally {
  if (Test-Path $options['tempDir']) {
    Remove-Item -Recurse -Force $options['tempDir']
  }
}
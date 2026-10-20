param([switch]$Lifecycle)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
function Assert-Check($condition, [string]$message) {
    if (-not $condition) { throw $message }
    Write-Host "PASS: $message"
}

$manifestPath = Join-Path $root 'bucket/chitchat.json'
Assert-Check (Test-Path -LiteralPath $manifestPath) 'Scoop manifest exists'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$download = Join-Path ([IO.Path]::GetTempPath()) ("chitchat-scoop-test-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $download | Out-Null
$installer = Join-Path $download 'installer.exe'
Invoke-WebRequest ($manifest.architecture.'64bit'.url -split '#')[0] -OutFile $installer
Assert-Check ((Get-FileHash $installer -Algorithm SHA256).Hash -eq $manifest.architecture.'64bit'.hash) 'Downloaded release matches manifest SHA-256'
$archiveTool = (Get-Command 7z -ErrorAction SilentlyContinue).Source
if (-not $archiveTool) { $archiveTool = "$env:ProgramFiles/7-Zip/7z.exe" }
& $archiveTool x $installer "-o$download/payload" -y | Out-Host
Assert-Check ($LASTEXITCODE -eq 0) 'NSIS payload extracts without running its installer'
foreach ($file in 'chitchat.exe', 'chitchatd.exe', 'chitchat.ico', 'ui/native/chitchat-ui.exe', 'THIRD-PARTY-NOTICES.md') {
    Assert-Check (Test-Path -LiteralPath (Join-Path "$download/payload" $file)) "Extracted $file"
}
if (-not $Lifecycle) { return }

Assert-Check ($env:GITHUB_ACTIONS -eq 'true' -and $env:RUNNER_ENVIRONMENT -eq 'github-hosted') 'Lifecycle test runs only on a disposable hosted runner'
Assert-Check (-not (Test-Path "$env:APPDATA/chitchat-sonnet")) 'No existing user settings'
Assert-Check (-not (Test-Path "$env:LOCALAPPDATA/chitchat-sonnet")) 'No existing speech data'
scoop bucket add bakken https://github.com/bakkensoftware/chitchat-releases
Assert-Check ($LASTEXITCODE -eq 0) 'Consumer bucket URL is usable'
New-Item -ItemType Directory -Path "$env:SCOOP/buckets/bakken/bucket" -Force | Out-Null
Copy-Item $manifestPath "$env:SCOOP/buckets/bakken/bucket/chitchat.json" -Force
scoop install bakken/chitchat
Assert-Check ($LASTEXITCODE -eq 0) 'Scoop installs ChitChat and dependencies'
$app = "$env:SCOOP\apps\chitchat\current"
Assert-Check ((& chitchat version) -match [regex]::Escape($manifest.version)) 'CLI shim resolves installed release'
& uv --version
Assert-Check ($LASTEXITCODE -eq 0) 'Declared uv dependency is executable'
$shortcut = Join-Path ([Environment]::GetFolderPath('StartMenu')) 'Programs/Scoop Apps/ChitChat.lnk'
Assert-Check (Test-Path -LiteralPath $shortcut) 'Start menu shortcut exists'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$startup = (Get-ItemProperty -LiteralPath $runKey -Name chitchat-sonnet -ErrorAction SilentlyContinue).'chitchat-sonnet'
Assert-Check ($startup -eq ('"' + "$app\chitchatd.exe" + '"')) 'Install registers the stable current daemon for this user at login'
$startupBytes = [IO.File]::ReadAllBytes("$app/chitchatd.exe")
$peOffset = [BitConverter]::ToInt32($startupBytes, 0x3c)
Assert-Check ([BitConverter]::ToUInt16($startupBytes, $peOffset + 92) -eq 2) 'Login target is a Windows GUI executable without a console subsystem'

& chitchat setup
Assert-Check ($LASTEXITCODE -eq 0) 'First-use engine and model setup succeeds'
$fixture = Join-Path $download 'speech.wav'
$env:CHITCHAT_SCOOP_FIXTURE = $fixture
@'
Add-Type -AssemblyName System.Speech
$voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
$format = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(16000, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$voice.SetOutputToWaveFile($env:CHITCHAT_SCOOP_FIXTURE, $format)
$voice.Speak('The quick brown fox jumps over the lazy dog.')
$voice.Dispose()
'@ | & powershell.exe -NoProfile -NonInteractive -Command -
Assert-Check ($LASTEXITCODE -eq 0 -and (Test-Path $fixture)) 'Non-sensitive speech fixture generated'
$transcript = (& chitchat transcribe $fixture | Out-String)
Assert-Check ($LASTEXITCODE -eq 0 -and $transcript -match 'quick brown fox') 'Installed local speech engine transcribes actual audio'

$python = "$env:LOCALAPPDATA/chitchat-sonnet/phonon/venv/Scripts/python.exe"
$httpsProbe = 'import urllib.request; urllib.request.urlopen("https://huggingface.co", timeout=8).close()'
& $python -c $httpsProbe
Assert-Check ($LASTEXITCODE -eq 0) 'Speech runtime can reach HTTPS before the offline check'
$runtimePaths = @(& $python -c 'import sys; print(sys.executable); print(sys._base_executable)')
$offlinePrograms = @($runtimePaths + @("$app/chitchat.exe", "$env:LOCALAPPDATA/chitchat-sonnet/phonon/venv/Scripts/fermion.exe", (Get-Command uv).Source)) |
    ForEach-Object { [IO.Path]::GetFullPath($_) } | Select-Object -Unique
$offlineRules = @()
try {
    Assert-Check (@(Get-NetFirewallProfile | Where-Object { -not $_.Enabled }).Count -eq 0) 'Windows Firewall is active for the offline check'
    foreach ($program in $offlinePrograms) {
        $offlineRules += New-NetFirewallRule -DisplayName ('ChitChat offline test ' + [guid]::NewGuid().ToString('N')) -Direction Outbound -Action Block -Program $program -RemoteAddress '0.0.0.0-126.255.255.255', '128.0.0.0-255.255.255.255', '::2-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    }
    & $python -c $httpsProbe 2>&1 | Out-Host
    Assert-Check ($LASTEXITCODE -ne 0) 'Speech runtime HTTPS fails while its internet access is blocked'
    $offlineTranscript = (& chitchat transcribe $fixture | Out-String)
    Assert-Check ($LASTEXITCODE -eq 0 -and $offlineTranscript -match 'quick brown fox') 'Default local model transcribes with internet blocked and loopback allowed'
} finally {
    $offlineRules | Remove-NetFirewallRule
}

$settings = "$env:APPDATA/chitchat-sonnet"
$data = "$env:LOCALAPPDATA/chitchat-sonnet"
New-Item -ItemType Directory -Path "$data/history", $settings -Force | Out-Null
'retained recording history' | Set-Content "$data/history/scoop-retention.txt"
@{ provider = 'mock'; hotkey = 'ctrl+alt+f10'; theme_key = ''; layout_key = '' } |
    ConvertTo-Json | Set-Content "$settings/config.json"
$settingsHash = (Get-FileHash "$settings/config.json").Hash
& "$download/payload/chitchat.exe" start
Assert-Check ($LASTEXITCODE -eq 0) 'Separate extracted installation starts'
$outsideDaemon = Get-Process chitchatd
scoop update chitchat --force
Assert-Check ($LASTEXITCODE -eq 0) 'Scoop updates while another installation is running'
Assert-Check (Get-Process -Id $outsideDaemon.Id -ErrorAction SilentlyContinue) 'Package hook leaves a separately installed daemon running'
& "$download/payload/chitchat.exe" stop
Assert-Check ($LASTEXITCODE -eq 0 -and $outsideDaemon.WaitForExit(10000)) 'Separate installation stops through its own CLI'
Start-Process -FilePath $startup.Trim('"') | Out-Null
Start-Sleep -Seconds 3
Assert-Check (@(Get-Process chitchatd -ErrorAction SilentlyContinue).Count -eq 1) 'Scoop-launched daemon is running before update'
$daemon = Get-Process chitchatd
Assert-Check ($daemon.Path -like "$env:SCOOP\apps\chitchat\*\chitchatd.exe") 'Registered login command launches the installed daemon'
Assert-Check ($daemon.MainWindowHandle -eq 0) 'Login daemon has no visible main window'
$consoleChildren = @(Get-CimInstance Win32_Process -Filter "ParentProcessId = $($daemon.Id)" | Where-Object { $_.Name -in 'cmd.exe', 'powershell.exe', 'pwsh.exe', 'conhost.exe', 'OpenConsole.exe' })
Assert-Check ($consoleChildren.Count -eq 0) 'Login daemon does not spawn a console host or shell'
scoop update chitchat --force
Assert-Check (Get-Process -Id $daemon.Id -ErrorAction SilentlyContinue) 'Scoop safely defers an update while the app is running'
& chitchat stop
Assert-Check ($LASTEXITCODE -eq 0 -and $daemon.WaitForExit(10000)) 'Documented stop command releases the installed application'
scoop update chitchat --force
Assert-Check ($LASTEXITCODE -eq 0) 'Scoop replaces the stopped installation'
Assert-Check ((Get-ItemProperty -LiteralPath $runKey -Name chitchat-sonnet).'chitchat-sonnet' -eq $startup) 'Forced reinstall retains the stable login command'
Assert-Check (-not (Get-Process chitchatd -ErrorAction SilentlyContinue)) 'Update does not launch the daemon'
Assert-Check ((Get-FileHash "$settings/config.json").Hash -eq $settingsHash) 'Update preserves settings'
Assert-Check ((Get-Content "$data/history/scoop-retention.txt") -eq 'retained recording history') 'Update preserves recording history'
Assert-Check ((& chitchat version) -match [regex]::Escape($manifest.version)) 'CLI shim still works after update'
& chitchat start
Assert-Check ($LASTEXITCODE -eq 0) 'Updated installation starts successfully'
scoop uninstall chitchat
Assert-Check ($LASTEXITCODE -eq 0) 'Scoop uninstalls a running installation'
Assert-Check (-not (Get-ItemProperty -LiteralPath $runKey -Name chitchat-sonnet -ErrorAction SilentlyContinue)) 'Uninstall removes its own login entry'
Assert-Check (-not (Test-Path -LiteralPath $app)) 'Uninstall removes application files'
Assert-Check (-not (Test-Path -LiteralPath $shortcut)) 'Uninstall removes the Scoop shortcut'
Assert-Check (-not (Get-Command chitchat -ErrorAction SilentlyContinue)) 'Uninstall removes the CLI shim'
Assert-Check ((Get-FileHash "$settings/config.json").Hash -eq $settingsHash) 'Uninstall preserves settings'
Assert-Check ((Get-Content "$data/history/scoop-retention.txt") -eq 'retained recording history') 'Uninstall preserves recording history'
Assert-Check (Test-Path "$data/phonon/venv/Scripts/fermion.exe") 'Uninstall retains the downloaded speech engine'

scoop install bakken/chitchat
Assert-Check ($LASTEXITCODE -eq 0) 'Scoop installs again for startup ownership regression'
$outsideStartup = '"' + "$download\payload\chitchatd.exe" + '"'
Set-ItemProperty -LiteralPath $runKey -Name chitchat-sonnet -Value $outsideStartup
scoop uninstall chitchat
Assert-Check ($LASTEXITCODE -eq 0) 'Scoop uninstalls after another installation claims startup'
Assert-Check ((Get-ItemProperty -LiteralPath $runKey -Name chitchat-sonnet).'chitchat-sonnet' -eq $outsideStartup) 'Uninstall preserves another installation login command'
Remove-ItemProperty -LiteralPath $runKey -Name chitchat-sonnet

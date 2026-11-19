# Run Stock Room on a physical Android phone (USB or wireless ADB).
# Points API_BASE at this PC's LAN IP so the phone can reach localhost:3000.
# Requires: backend listening on 0.0.0.0:3000, phone + PC on same Wi-Fi.

$ErrorActionPreference = 'Stop'
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$adb = "$sdk\platform-tools\adb.exe"

$env:JAVA_HOME = 'C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot'
$env:PATH = "$env:JAVA_HOME\bin;C:\src\flutter\bin;$sdk\platform-tools;$env:PATH"
$env:GRADLE_USER_HOME = "$env:USERPROFILE\.gradle"

if (-not (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
  throw "JDK 17 not found at $env:JAVA_HOME"
}

# Prefer a private LAN IPv4 (skip APIPA 169.254.*)
$ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
  Where-Object {
    $_.IPAddress -notlike '127.*' -and
    $_.IPAddress -notlike '169.254.*' -and
    $_.PrefixOrigin -ne 'WellKnown'
  } |
  Sort-Object -Property InterfaceMetric |
  Select-Object -First 1 -ExpandProperty IPAddress

if (-not $ip) {
  throw 'No LAN IPv4 found. Connect PC to Wi-Fi and retry.'
}

$apiBase = "http://${ip}:3000/api/v1"
Write-Host "API_BASE=$apiBase"

# Smoke-check backend on LAN (same path the phone will use)
try {
  $null = Invoke-WebRequest -Uri "$apiBase/auth/login" -Method POST -ContentType 'application/json' `
    -Body '{"identifier":"__ping__","password":"x"}' -UseBasicParsing -TimeoutSec 3
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  if (-not $code) {
    throw "Backend not reachable at $apiBase — start backend, allow firewall TCP 3000, same Wi-Fi."
  }
  # 4xx from login is fine; means HTTP reached the API
}

$deviceLine = (& $adb devices) | Where-Object { $_ -match '\tdevice$' -and $_ -notmatch '^emulator-' }
if (-not $deviceLine) {
  throw 'No physical Android device connected. Plug USB or pair wireless debugging, then retry.'
}
$id = (($deviceLine | Select-Object -First 1) -split '\s+')[0]
Write-Host "Device: $id"

# USB/wireless reverse helps when LAN is flaky; harmless if it fails
& $adb -s $id reverse tcp:3000 tcp:3000 2>$null | Out-Null

flutter run -d $id --dart-define=API_BASE=$apiBase
exit $LASTEXITCODE

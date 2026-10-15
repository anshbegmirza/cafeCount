# CafeCount live screenshot capture (EN + AR) via ADB
$ErrorActionPreference = "Stop"
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dumpPath = Join-Path $root "_uidump.xml"
$deviceDump = "/sdcard/cc_uidump.xml"
$deviceShot = "/sdcard/cc_shot.png"
$trRoot = Join-Path (Split-Path $root -Parent) "mobile\assets\translations"

function Invoke-Adb {
  param([Parameter(Mandatory=$true)][string[]]$Cmd)
  & $adb @Cmd
}

function Get-Labels([string]$Lang) {
  $j = Get-Content -Raw -Encoding UTF8 (Join-Path $trRoot "$Lang.json") | ConvertFrom-Json
  return @{
    home = [string]$j.home
    products = [string]$j.products
    settings = [string]$j.settings
    about = [string]$j.about
    withdrawStock = [string]$j.withdrawStock
    history = [string]$j.history
    staff = [string]$j.staff
    reports = [string]$j.reports
    logout = [string]$j.logout
    logoutConfirm = [string]$j.logoutConfirmAction
    login = [string]$j.login
    languageEn = [string]$j.languageEn
    languageAr = [string]$j.languageAr
    menu = [string]$j.menu
  }
}

function Get-UiDump {
  Invoke-Adb -Cmd @("shell","uiautomator","dump",$deviceDump) | Out-Null
  Invoke-Adb -Cmd @("pull",$deviceDump,$dumpPath) | Out-Null
  [xml](Get-Content -Raw -Encoding UTF8 $dumpPath)
}

function Get-BoundsCenter([string]$bounds) {
  if ($bounds -notmatch "\[(\d+),(\d+)\]\[(\d+),(\d+)\]") { return $null }
  $x1=[int]$Matches[1]; $y1=[int]$Matches[2]; $x2=[int]$Matches[3]; $y2=[int]$Matches[4]
  [pscustomobject]@{ X = [int](($x1+$x2)/2); Y = [int](($y1+$y2)/2); W = ($x2-$x1); H = ($y2-$y1) }
}

function Find-Node {
  param([xml]$Doc, [string]$ContentDesc, [string]$ContentDescRegex, [switch]$ClickableOnly)
  foreach ($n in $Doc.SelectNodes("//node")) {
    $cd = [string]$n.GetAttribute("content-desc")
    $click = $n.GetAttribute("clickable") -eq "true"
    if ($ClickableOnly -and -not $click) { continue }
    if ($ContentDesc -and $cd -ne $ContentDesc) { continue }
    if ($ContentDescRegex -and $cd -notmatch $ContentDescRegex) { continue }
    $c = Get-BoundsCenter $n.GetAttribute("bounds")
    if ($c) { return $c }
  }
  return $null
}

function Tap-Desc {
  param([string]$Desc, [string]$Regex, [int]$WaitMs = 900)
  $doc = Get-UiDump
  $node = $null
  if ($Desc) { $node = Find-Node -Doc $doc -ContentDesc $Desc -ClickableOnly }
  if (-not $node -and $Regex) { $node = Find-Node -Doc $doc -ContentDescRegex $Regex -ClickableOnly }
  if (-not $node -and $Desc) { $node = Find-Node -Doc $doc -ContentDesc $Desc }
  if (-not $node -and $Regex) { $node = Find-Node -Doc $doc -ContentDescRegex $Regex }
  if (-not $node) { throw "UI node not found: desc='$Desc' regex='$Regex'" }
  Write-Host ("  tap {0},{1} [{2}{3}]" -f $node.X, $node.Y, $Desc, $Regex)
  Invoke-Adb -Cmd @("shell","input","tap","$($node.X)","$($node.Y)") | Out-Null
  Start-Sleep -Milliseconds $WaitMs
}

function Tap-XY {
  param([int]$X, [int]$Y, [int]$WaitMs = 700)
  Invoke-Adb -Cmd @("shell","input","tap","$X","$Y") | Out-Null
  Start-Sleep -Milliseconds $WaitMs
}

function Save-Shot {
  param([string]$Lang, [string]$Name)
  $dir = Join-Path $root $Lang
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $dest = Join-Path $dir "$Name.png"
  # IMPORTANT: quote remote command so PowerShell never eats -p
  Invoke-Adb -Cmd @("shell","screencap -p $deviceShot") | Out-Null
  if (Test-Path $dest) { Remove-Item -Force $dest }
  Invoke-Adb -Cmd @("pull",$deviceShot,$dest) | Out-Null
  $bytes = [System.IO.File]::ReadAllBytes($dest)
  $magic = [BitConverter]::ToString($bytes[0..3])
  if ($magic -ne "89-50-4E-47") { throw "Bad PNG: $dest ($magic)" }
  $hash = (Get-FileHash -Algorithm MD5 -Path $dest).Hash.Substring(0,8)
  Write-Host ("  saved {0}/{1}.png ({2} bytes, md5={3})" -f $Lang, $Name, $bytes.Length, $hash)
}

function Hide-Keyboard {
  Invoke-Adb -Cmd @("shell","input","keyevent","4") | Out-Null
  Start-Sleep -Milliseconds 500
}

function Open-Drawer {
  param($L)
  try { Tap-Desc -Desc $L.menu -WaitMs 1000 }
  catch {
    try { Tap-Desc -Desc "Menu" -WaitMs 1000 }
    catch { Write-Host "  menu fallback tap 79,174"; Tap-XY 79 174 -WaitMs 1000 }
  }
}

function Go-Home {
  param($L)
  try { Tap-Desc -Desc $L.home -WaitMs 800 }
  catch {
    # After locale switch, bottom-nav semantics sometimes lag — tap left tab
    Write-Host "  home fallback tap 180,2115"
    Tap-XY 180 2115 -WaitMs 800
  }
}

function Clear-And-Type {
  param([int]$X, [int]$Y, [string]$Text)
  Tap-XY $X $Y -WaitMs 400
  # move end, delete lots, type
  Invoke-Adb -Cmd @("shell","input","keyevent","123") | Out-Null
  1..48 | ForEach-Object { Invoke-Adb -Cmd @("shell","input","keyevent","67") | Out-Null }
  # adb input text: escape spaces as %s; avoid shell metacharacters
  $safe = $Text.Replace(" ", "%s")
  Invoke-Adb -Cmd @("shell","input","text",$safe) | Out-Null
  Start-Sleep -Milliseconds 350
}

function Login-ShopAdmin {
  param($L)
  Start-Sleep -Milliseconds 800
  $doc = Get-UiDump
  $edits = @($doc.SelectNodes("//node[@class='android.widget.EditText']"))
  if ($edits.Count -lt 2) {
    Hide-Keyboard
    Start-Sleep -Milliseconds 600
    $doc = Get-UiDump
    $edits = @($doc.SelectNodes("//node[@class='android.widget.EditText']"))
  }
  if ($edits.Count -lt 2) { throw "Login EditTexts not found ($($edits.Count))" }
  $u = Get-BoundsCenter $edits[0].GetAttribute("bounds")
  # Tap user only, then TAB into password — keyboard shifts layout so old Y coords hit keys
  Tap-XY $u.X $u.Y -WaitMs 400
  # clear any leftover text
  Invoke-Adb -Cmd @("shell","input","keyevent","123") | Out-Null
  1..40 | ForEach-Object { Invoke-Adb -Cmd @("shell","input","keyevent","67") | Out-Null }
  Invoke-Adb -Cmd @("shell","input","text","shopadmin") | Out-Null
  Start-Sleep -Milliseconds 350
  Invoke-Adb -Cmd @("shell","input","keyevent","61") | Out-Null  # TAB -> password
  Start-Sleep -Milliseconds 350
  Invoke-Adb -Cmd @("shell","input","text","test123") | Out-Null
  Start-Sleep -Milliseconds 350
  Hide-Keyboard
  Start-Sleep -Milliseconds 600
  Tap-Desc -Desc $L.login -WaitMs 3500
  # confirm we left login
  $doc2 = Get-UiDump
  $stillLogin = Find-Node -Doc $doc2 -ContentDesc $L.login -ClickableOnly
  if ($stillLogin) { throw "Login failed — still on login screen" }
}

function Ensure-Lang {
  param([string]$Want, $En, $Ar)
  $L = if ($Want -eq "en") { $En } else { $Ar }
  $doc = Get-UiDump
  if (Find-Node -Doc $doc -ContentDesc $En.home -ClickableOnly) { Tap-Desc -Desc $En.home -WaitMs 700 }
  elseif (Find-Node -Doc $doc -ContentDesc $Ar.home -ClickableOnly) { Tap-Desc -Desc $Ar.home -WaitMs 700 }

  $doc = Get-UiDump
  if (Find-Node -Doc $doc -ContentDesc $En.settings -ClickableOnly) { Tap-Desc -Desc $En.settings -WaitMs 900 }
  elseif (Find-Node -Doc $doc -ContentDesc $Ar.settings -ClickableOnly) { Tap-Desc -Desc $Ar.settings -WaitMs 900 }
  else { throw "Settings tab not found" }

  $doc = Get-UiDump
  $btnAr = Find-Node -Doc $doc -ContentDesc $En.languageAr -ClickableOnly
  $btnEn = Find-Node -Doc $doc -ContentDesc $En.languageEn -ClickableOnly
  if ($Want -eq "en") {
    if ($btnEn -and -not $btnAr) {
      Write-Host "  switching to English..."
      Tap-Desc -Desc $En.languageEn -WaitMs 1200
    } else { Write-Host "  language OK for English" }
  } else {
    if ($btnAr) {
      Write-Host "  switching to Arabic..."
      Tap-Desc -Desc $En.languageAr -WaitMs 1200
    } else { Write-Host "  language OK for Arabic" }
  }
  Go-Home -L $L
}

function Capture-Suite {
  param([string]$Lang, $L)
  Write-Host "`n=== Capturing $Lang ==="
  Go-Home -L $L
  Start-Sleep -Milliseconds 600
  Save-Shot $Lang "01_home_dashboard"

  try { Tap-Desc -Desc $L.products -WaitMs 1100 } catch { Tap-XY 540 2115 -WaitMs 1100 }
  Save-Shot $Lang "02_products"

  try { Tap-Desc -Desc $L.settings -WaitMs 1100 } catch { Tap-XY 900 2115 -WaitMs 1100 }
  Save-Shot $Lang "03_settings"

  try {
    Tap-Desc -Regex ("^" + [regex]::Escape($L.about)) -WaitMs 1000
    Save-Shot $Lang "04_about"
    Invoke-Adb -Cmd @("shell","input","keyevent","4") | Out-Null
    Start-Sleep -Milliseconds 700
  } catch { Write-Host "  skip about: $_" }

  Go-Home -L $L
  Open-Drawer -L $L
  Save-Shot $Lang "05_drawer_menu"
  Tap-Desc -Desc $L.withdrawStock -WaitMs 1100
  Save-Shot $Lang "06_withdraw"

  Open-Drawer -L $L
  Tap-Desc -Desc $L.history -WaitMs 1100
  Save-Shot $Lang "07_history"

  Open-Drawer -L $L
  Tap-Desc -Desc $L.staff -WaitMs 1100
  Save-Shot $Lang "08_staff"

  Open-Drawer -L $L
  Tap-Desc -Desc $L.reports -WaitMs 1100
  Save-Shot $Lang "09_reports"

  Go-Home -L $L
  try { Tap-Desc -Desc $L.settings -WaitMs 900 } catch { Tap-XY 900 2115 -WaitMs 900 }
  Tap-Desc -Regex ("^" + [regex]::Escape($L.logout)) -WaitMs 900
  Tap-Desc -Desc $L.logoutConfirm -WaitMs 1600
  Save-Shot $Lang "10_login"

  Login-ShopAdmin -L $L
  Save-Shot $Lang "11_home_after_login"
}

# clean previous bad identical shots

Write-Host "AR-only capture..."
$en = Get-Labels "en"
$ar = Get-Labels "ar"
Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $root "ar\*.png")
Invoke-Adb -Cmd @("shell","input","keyevent","4") | Out-Null
Invoke-Adb -Cmd @("shell","am","start","-n","com.cafecount.cafecount/.MainActivity") | Out-Null
Start-Sleep -Seconds 2
Ensure-Lang -Want "ar" -En $en -Ar $ar
Capture-Suite -Lang "ar" -L $ar
Ensure-Lang -Want "en" -En $en -Ar $ar
Write-Host "AR DONE."
Get-ChildItem (Join-Path $root "en"), (Join-Path $root "ar") -Filter *.png | Sort-Object Directory, Name | Format-Table Name, Length, Directory -AutoSize
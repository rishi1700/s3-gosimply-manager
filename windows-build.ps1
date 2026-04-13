# ./build-windows.ps1
# ------------------------------------------------------------
# Build PyInstaller EXE (and optionally codesign) on Windows.
# ------------------------------------------------------------

$ErrorActionPreference = "Stop"

# ---- Settings you may tweak ----
$PythonVersion   = "3.12"          # any installed Python is fine
$VenvPath        = ".\.venv"
$EntryScript     = "app.py"        # main script
$AppName         = "S3_GoSimply_Manager"
$IconPath        = "app.ico"       # optional; remove if you don't have one
$HiddenImports   = @("minio","urllib3","tqdm","PIL")  # pillow registers as PIL
$DistExe         = ".\dist\$AppName.exe"
# Codesign (optional): place your PFX next to this script and set env var:
#   $Env:WIN_CERT_PFX_PASSWORD = "your-password"
$PfxPath         = "codesign.pfx"  # if file exists and password set, we sign
$TimeStampUrl    = "http://timestamp.digicert.com"

# ---- Helper ----
function Use-Python {
    param([string]$Args)
    & "$VenvPath\Scripts\python.exe" -c "import sys;print(sys.version)" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Python venv not ready." }
    & "$VenvPath\Scripts\python.exe" @Args
}

# ---- Ensure Python on PATH ----
$python = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $python) { throw "Python not found. Install Python $PythonVersion from python.org and re-run." }

# ---- Create venv & install deps ----
if (-not (Test-Path $VenvPath)) {
    python -m venv $VenvPath
}
& "$VenvPath\Scripts\Activate.ps1"

python -m pip install --upgrade pip
if (Test-Path ".\requirements.txt") {
    pip install -r .\requirements.txt
} else {
    pip install pyinstaller minio urllib3 tqdm pillow
}

# ---- Build with PyInstaller ----
$hiddenArgs = @()
foreach ($h in $HiddenImports) { $hiddenArgs += @("--hidden-import", $h) }

$iconArgs = @()
if (Test-Path $IconPath) { $iconArgs = @("--icon", $IconPath) }

pyinstaller --noconfirm --clean --onefile --windowed `
  --name $AppName `
  @iconArgs `
  @hiddenArgs `
  $EntryScript

Write-Host "`nBuild output tree:"
Get-ChildItem .\dist -Recurse | ForEach-Object { $_.FullName }

if (-not (Test-Path $DistExe)) {
    throw "Expected single-file output '$DistExe' not found."
}

# ---- Optional Code Signing ----
$shouldSign = (Test-Path $PfxPath) -and $Env:WIN_CERT_PFX_PASSWORD
if ($shouldSign) {
    Write-Host "`nSigning binaries with $PfxPath ..."
    # Find signtool.exe
    $signtool = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\x64\signtool.exe"
    if (-not (Test-Path $signtool)) {
        $signtool = (Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin" -Recurse -Filter signtool.exe |
                     Select-Object -Last 1).FullName
    }
    if (-not (Test-Path $signtool)) { throw "signtool.exe not found. Install Windows 10 SDK or Visual Studio Build Tools." }

    $bins = @(Get-Item $DistExe)
    if ($bins.Count -eq 0) { throw "No binary to sign at $DistExe." }

    foreach ($b in $bins) {
        & $signtool sign `
            /fd SHA256 `
            /f $PfxPath `
            /p $Env:WIN_CERT_PFX_PASSWORD `
            /tr $TimeStampUrl `
            /td SHA256 `
            "$($b.FullName)"
    }

    Write-Host "`nVerifying signatures..."
    foreach ($b in $bins) {
        & $signtool verify /pa "$($b.FullName)"
    }
} else {
    Write-Host "`nSkipping code signing (no PFX or password)."
}

Write-Host "`nDone. Final app file: $DistExe"

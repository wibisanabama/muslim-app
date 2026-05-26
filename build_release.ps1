# build_release.ps1
# Build release APK dan rename output menjadi muslim-app.apk

$OutputDir = "build\app\outputs\flutter-apk"
$SourceApk = "$OutputDir\app-release.apk"
$TargetApk = "$OutputDir\muslim-app.apk"

Write-Host "Building release APK..." -ForegroundColor Cyan
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build FAILED." -ForegroundColor Red
    exit 1
}

if (Test-Path $SourceApk) {
    if (Test-Path $TargetApk) {
        Remove-Item $TargetApk -Force
    }
    Rename-Item -Path $SourceApk -NewName "muslim-app.apk"
    Write-Host ""
    Write-Host "APK renamed -> $TargetApk" -ForegroundColor Green
} else {
    Write-Host "ERROR: $SourceApk not found." -ForegroundColor Red
    exit 1
}

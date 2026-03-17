# Delete temp files for all users
$userProfiles = Get-ChildItem "C:\Users" | Where-Object { $_.PSIsContainer -and $_.Name -notin @("Public", "Default", "Default User") }

foreach ($profile in $userProfiles) {
    $tempPath = Join-Path $profile.FullName "AppData\Local\Temp"
    if (Test-Path $tempPath) {
        try {
            Get-ChildItem $tempPath -File | Remove-Item -Force
            Write-Host "Deleted temp files for user: $($profile.Name)"
        } catch {
            Write-Host "Error deleting temp files for $($profile.Name): $($_.Exception.Message)"
        }
    } else {
        Write-Host "Temp folder not found for user: $($profile.Name)"
    }
}

Write-Host "Temp file cleanup completed."
# Delete temp files for all users on a single machine
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

# Delete temp files for all users across a subnet

# Prompt for subnet (e.g., "192.168.1.0/24")
$subnet = Read-Host "Enter the subnet (e.g., 192.168.1.0/24)"

# Get computers in the subnet (requires Active Directory module)
$computers = Get-ADComputer -Filter * | Where-Object { $_.IPv4Address -like "$($subnet.Split('/')[0].Split('.')[0..2] -join '.').*" }

foreach ($computer in $computers) {
    try {
        Invoke-Command -ComputerName $computer.Name -ScriptBlock {
            $userProfiles = Get-ChildItem "C:\Users" | Where-Object { $_.PSIsContainer -and $_.Name -notin @("Public", "Default", "Default User") }
            foreach ($profile in $userProfiles) {
                $tempPath = Join-Path $profile.FullName "AppData\Local\Temp"
                if (Test-Path $tempPath) {
                    Get-ChildItem $tempPath -File | Remove-Item -Force
                    Write-Host "Deleted temp files for user: $($profile.Name) on $($env:COMPUTERNAME)"
                } else {
                    Write-Host "Temp folder not found for user: $($profile.Name) on $($env:COMPUTERNAME)"
                }
            }
            Write-Host "Temp file cleanup completed on $($env:COMPUTERNAME)."
        } -ErrorAction Stop
    } catch {
        Write-Host "Error on $($computer.Name): $($_.Exception.Message)"
    }
}

Write-Host "Subnet-wide temp file cleanup completed."
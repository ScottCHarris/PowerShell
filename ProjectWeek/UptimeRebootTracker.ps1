# Uptime and Reboot Tracker for single computer:

## Getting to default on blank to local was hard
$computerName = Read-Host "Enter the computer name (leave blank for local)"
if ([string]::IsNullOrWhiteSpace($computerName)) {$computerName = $env:COMPUTERNAME}
$lastBoot = $os.LastBootUpTime
$uptime   = ((Get-Date) - $lastBoot).days
## Make sure you convert the read-host to an integer
$threshold = [int](Read-Host "Enter uptime threshold in days")
$reviewPoint = [math]::Round($threshold * 0.75)

try {$os = Get-CimInstance Win32_OperatingSystem -ComputerName $computerName -ErrorAction Stop}
catch {Write-Host "Failed to query $computerName" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red return}
                    
if ($uptime -gt $threshold) {$status = "Overdue"
                             $statusLabel = "FAIL"
                             $color = "Red"}
    elseif ($uptime -ge $reviewPoint) {$status = "Review"
                                        $statusLabel = "WARNING"
                                        $color = "Yellow"}
    else {$status = "Normal"
            $statusLabel = "PASS"
            $color = "Green"}

## Originally I had this as a hashtable but prject required custom object
$result = [PSCustomObject]@{ComputerName = $computerName
                            LastBootTime = $lastBoot
                            UptimeDays   = $uptime
                            Status       = $status
                            Indicator    = $statusLabel}

$result | Format-List

Write-Host "`nStatus: $statusLabel ($status)" -ForegroundColor $color

# Uptime and Reboot Tracker for network or subnet:
Write-Host "Choose scan type:"
Write-Host "1. Entire network"
Write-Host "2. Subnet"
$scanChoice = Read-Host "Enter 1 or 2"
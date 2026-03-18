## Network or subnet is line 37 and includes single computer
# Uptime and Reboot Tracker for single computer 

## Getting to default on blank to local was hard
$computerName = Read-Host "Enter the computer name (leave blank for local)"
if ([string]::IsNullOrWhiteSpace($computerName)) {$computerName = $env:COMPUTERNAME}
$lastBoot = $os.LastBootUpTime
$uptime   = ((Get-Date) - $lastBoot).days
## Make sure you convert the read-host to an integer
$threshold = [int](Read-Host "Enter days since reboot threshold in days")
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

# Uptime and Reboot Tracker for network or subnet or single computer:

# ============================
# From CPilot with a few small Scott Harris tweaks
# ============================

Write-Host "Choose scan type:"
Write-Host "1. Entire AD Network"
Write-Host "2. Subnet Scan"
Write-Host "3. Manual Computer List (choose this for local)"
$choice = Read-Host "Enter 1, 2, or 3"

# Accept threshold
$threshold = [int](Read-Host "Enter uptime threshold in days")
$reviewPoint = [math]::Round($threshold * 0.75)

# Collect target computers
$computers = @()

switch ($choice) {

    "1" {
        Write-Host "Querying Active Directory..."
        $computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
    }

    "2" {
        $subnet = Read-Host "Enter subnet prefix (example: 192.168.1)"
        foreach ($i in 1..254) {
            $ip = "$subnet.$i"
            if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
                $computers += $ip
            }
        }
    }

    "3" {
        $list = Read-Host "Enter computer names separated by commas (blank = local)"

        if ([string]::IsNullOrWhiteSpace($list)) {
            # Default to local machine
            $computers = @($env:COMPUTERNAME)
        }
        else {
            # Split into one or more computers
            $computers = $list.Split(",") | ForEach-Object { $_.Trim() }
        }
    }

    default {
        Write-Host "Invalid selection." -ForegroundColor Red
        return
    }
}

# Store results
$results = @()

foreach ($computer in $computers) {

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $lastBoot = $os.LastBootUpTime
        $days = ((Get-Date) - $lastBoot).Days

        # Classification
        if ($days -gt $threshold) {
            $status = "Overdue"
            $indicator = "FAIL"
            $color = "Red"
        }
        elseif ($days -ge $reviewPoint) {
            $status = "Review"
            $indicator = "WARNING"
            $color = "Yellow"
        }
        else {
            $status = "Normal"
            $indicator = "PASS"
            $color = "Green"
        }

        # Color-coded summary line
        Write-Host "$computer : $indicator ($status)" -ForegroundColor $color

        # Build object
        $results += [PSCustomObject]@{
            ComputerName = $computer
            LastBootTime = $lastBoot
            UptimeDays   = $days
            Status       = $status
            Indicator    = $indicator
        }
    }
    catch {
        # Query failed (offline, DNS fail, CIM fail, access denied, etc.)
        Write-Host "$computer : FAIL (Query Failed)" -ForegroundColor DarkYellow

        $results += [PSCustomObject]@{
            ComputerName = $computer
            LastBootTime = $null
            UptimeDays   = $null
            Status       = "Failed"
            Indicator    = "FAIL"
        }
    }
}

# Display results table
Write-Host "`n===== UPTIME RESULTS ====="
$results | Format-Table -AutoSize

# Optional CSV export
$export = Read-Host "`nExport results to CSV? (y/n)"
if ($export -eq "y") {
    $path = Read-Host "Enter CSV path (example: C:\uptime.csv)"
    $results | Export-Csv -Path $path -NoTypeInformation
    Write-Host "Exported to $path" -ForegroundColor Green
}
# Event Log Summary Reporter: 

#Summarize recent Windows event log errors and warnings.

param(
    [Parameter(Mandatory=$true)][string[]]$LogName,
    [Parameter(Mandatory=$true)][int]$HoursBack
)

$status = "PASS"
$startTime = (Get-Date).AddHours(-$HoursBack)

$allSummary = @()
$allDetails = @()

foreach ($log in $LogName) {

    Write-Host "`n=== LOG: $log ===" -ForegroundColor Cyan

    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName=$log
            Level=2,3
            StartTime=$startTime
        } -ErrorAction Stop

        if (-not $events) {
            Write-Host "No Error or Warning events found." -ForegroundColor Green
            continue
        }

        Write-Host "`nSUMMARY BY EVENT ID AND PROVIDER" -ForegroundColor Yellow

        $summary = $events |
            Group-Object Id,ProviderName |
            Sort-Object Count -Descending

        $top = $summary[0]
        $topID = $top.Group[0].Id
        $topCount = $top.Count

        Write-Host "Most common event: ID $topID ($topCount occurrences)" -ForegroundColor Magenta

        if ($topCount -gt 5) { $status = "WARNING" }

        $summaryObj = $summary |
            Select-Object `
                @{Name="Log";Expression={ $log }},
                @{Name="EventID";Expression={ $_.Group[0].Id }},
                @{Name="Provider";Expression={ $_.Group[0].ProviderName }},
                @{Name="Count";Expression={ $_.Count }}

        $summaryObj | Format-Table -AutoSize
        $allSummary += $summaryObj

        Write-Host "`nRECENT EVENT DETAILS" -ForegroundColor Yellow

        $detailsObj = $events |
            Select-Object -First 50 `
                @{Name="Log";Expression={ $log }},
                TimeCreated,
                LogName,
                ProviderName,
                Id,
                LevelDisplayName,
                @{Name="MessageShort";Expression={ $_.Message.Split("`n")[0] }}

        $detailsObj | Format-Table -AutoSize
        $allDetails += $detailsObj
    }
    catch {
        Write-Host "FAIL: Log query failed for $log. $($_.Exception.Message)" -ForegroundColor Red
        $status = "FAIL"
    }
}

# ============================
# Export Option
# ============================

$export = Read-Host "`nExport results? (csv / html / both / no)"

if ($export -eq "csv" -or $export -eq "both") {
    $csvPath = Read-Host "Enter CSV path (example: C:\events.csv)"
    $allDetails | Export-Csv $csvPath -NoTypeInformation
    Write-Host "CSV exported to $csvPath" -ForegroundColor Green
}

if ($export -eq "html" -or $export -eq "both") {
    $htmlPath = Read-Host "Enter HTML path (example: C:\events.html)"
    $allDetails | ConvertTo-Html -Title "Event Summary" | Out-File $htmlPath
    Write-Host "HTML exported to $htmlPath" -ForegroundColor Green
}

Write-Host "`nOverall Status: $status"
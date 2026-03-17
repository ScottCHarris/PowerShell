# Find new users created in the last 48 hours and 168 hours, and export to CSV
$currentDate = Get-Date
$date48HoursAgo = $currentDate.AddHours(-48)
$date168HoursAgo = $currentDate.AddHours(-168)

# Get users created in the last 48 hours
$users48Hours = Get-ADUser -Filter { whenCreated -ge $date48HoursAgo } -Properties whenCreated | Select-Object SamAccountName, Name, whenCreated

# Get users created in the last 168 hours
$users168Hours = Get-ADUser -Filter { whenCreated -ge $date168HoursAgo } -Properties whenCreated | Select-Object SamAccountName, Name, whenCreated

# Export to CSV
$users48Hours | Export-Csv -Path "c:\GitHubRepositories\PowerShell\ProjectWeek\UsersLast48Hours.csv" -NoTypeInformation
$users168Hours | Export-Csv -Path "c:\GitHubRepositories\PowerShell\ProjectWeek\UsersLast168Hours.csv" -NoTypeInformation

# Output confirmation
Write-Host "Exported users created in the last 48 hours to UsersLast48Hours.csv"
Write-Host "Exported users created in the last 168 hours to UsersLast168Hours.csv"

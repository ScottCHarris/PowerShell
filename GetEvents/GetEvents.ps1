$logname = 'system'
$newest = (Read-Host "Please enter the number of events you would like returned")
Get-EventLog -LogName $logname -newest 3
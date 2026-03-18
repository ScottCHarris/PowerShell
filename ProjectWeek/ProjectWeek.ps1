#Assigned Projects, student 13, numbers 10 and 11

# Project 10: Uptime and Reboot Tracker:
$computerName = Read-Host "Enter the computer name to check uptime and reboot history"
$lastBootTime = (Get-CimInstance -Class Win32_OperatingSystem -ComputerName $computerName).LastBootUpTime
$uptime = ((Get-Date) - $lastBootTime).Days

# Make sure you convert the read-host to an integer
$uptimethreshold = [int](Read-Host "Enter the uptime in days")


#Project 11: Event Log Summary Reporter: 


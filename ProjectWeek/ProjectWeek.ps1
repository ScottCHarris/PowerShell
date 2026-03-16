# Create list of AD computers that have not logged onto the network within 30 days, or the oldest logon if none > 30 days

$cutoff = (Get-Date).AddDays(-30)

Get-ADComputer -Filter * -Properties lastLogonTimestamp |
    Where-Object {
                [DateTime]::FromFileTime($_.lastLogonTimestamp) -lt $cutoff
                    } |
                        Select-Object Name, @{Name="LastLogonDate";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
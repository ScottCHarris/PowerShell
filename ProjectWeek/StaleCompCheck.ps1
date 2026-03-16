# Create list of AD computers that have not logged onto the network within 30 days

$cutoff = (Get-Date).AddDays(-30)

$stale = Get-ADComputer -Filter * -Properties lastLogonTimestamp |
    Select-Object Name,
                      @{n='LastLogonDate';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |
                          Where-Object { $_.LastLogonDate -lt $cutoff }

#Check last logon if checking for >30 days is empty list

if ($stale.Count -gt 0) {
        $stale
}
else {
        Get-ADComputer -Filter * -Properties lastLogonTimestamp |
                Select-Object Name,
                                      @{n='LastLogonDate';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |
                                              Sort-Object LastLogonDate |
                                                      Select-Object -First 1
                                                      }

#Full Script

$cutoff = (Get-Date).AddDays(-30)

$stale = Get-ADComputer -Filter * -Properties lastLogonTimestamp |
    Select-Object Name,
                      @{n='LastLogonDate';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |
                          Where-Object { $_.LastLogonDate -lt $cutoff }

                          if ($stale.Count -gt 0) {
                                # Return all stale computers
                                    $stale
                                    }
                                    else {
                                            # No stale computers → return the single oldest
                                                Get-ADComputer -Filter * -Properties lastLogonTimestamp |
                                                        Select-Object Name,
                                                                              @{n='LastLogonDate';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |
                                                                                      Sort-Object -Property LastLogonDate |
                                                                                              Select-Object -First 1
                                                                                              }
                          
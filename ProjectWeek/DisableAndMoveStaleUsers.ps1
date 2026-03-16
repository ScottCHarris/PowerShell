#Create the OU first (line 34) if not already created or error will occur when trying to move disabled accounts.
#Disable AD users inactive for 30+ days and move into "Disabled Users" OU

$cutoff = (Get-Date).AddDays(-30)

# Get users whose last logon is older than 30 days
$staleUsers = Get-ADUser -Filter * -Properties lastLogonTimestamp |
    Select-Object SamAccountName,
                      DistinguishedName,
                                        @{n='LastLogonDate';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |
                                            Where-Object { $_.LastLogonDate -lt $cutoff -or $_.LastLogonDate -eq $null }

                                            # Disable each stale account
                                            foreach ($user in $staleUsers) {
                                                    Disable-ADAccount -Identity $user.SamAccountName
                                                        Write-Host "Disabled: $($user.SamAccountName) — Last logon: $($user.LastLogonDate)"
                                                        }


# Move disabled accounts to "Disabled Users" OU
$disabledOU = "OU=Disabled Users,DC=adatum,DC=com"

foreach ($user in $staleUsers) {
    $disabledUser = Get-ADUser -Identity $user.SamAccountName
    if ($disabledUser.Enabled -eq $false) {
        Move-ADObject -Identity $disabledUser.DistinguishedName -TargetPath $disabledOU
        Write-Host "Moved: $($user.SamAccountName) to Disabled Users OU"
    }
}

#OU "Disabled Users" should already exist in the AD structure for this script to work properly.
#Creating OU if not already created:

New-ADOrganizationalUnit -Name "Disabled Users" -Path "DC=Adatum,DC=com" -ProtectedFromAccidentalDeletion $true
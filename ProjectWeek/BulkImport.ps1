# Add bulk users in AD

# Start with a CSV file containing the following columns:
    # GivenName, Surname, SamAccountName, UserPrincipalName, OU, Password
    #Make sure OU isn't split into multiple columns
    #Make sure to use -Name, both CoPilot and the VS agent missed this
        #Found it because it was asking for a name after I ran the script
        
$csvPath = "C:\GitHubRepositories\PowerShell\ProjectWeek\users.csv"
$users = Import-Csv -Path $csvPath

foreach ($u in $users) {
        New-ADUser `
                -GivenName $u.FirstName `
                -Surname $u.LastName `
                -name "$($u.FirstName) $($u.LastName)" `
                -SamAccountName $u.SamAccountName `
                -UserPrincipalName $u.UserPrincipalName `
                -AccountPassword (ConvertTo-SecureString $u.Password -AsPlainText -Force) `
                -Path $u.OU `
                -Enabled $true
                        }
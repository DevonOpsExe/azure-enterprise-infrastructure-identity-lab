Import-Module ActiveDirectory

$csvPath   = "C:\AD_Bulk_Import\mock_users.csv"
$users     = Import-Csv -Path $csvPath
$DomainDN  = (Get-ADDomain).DistinguishedName
$BaseOU    = "OU=Prod_Enterprise,$DomainDN"

foreach ($user in $users) {
    $Dept            = $user.department
    $TargetGroupOU   = "OU=$Dept-Groups,OU=Groups,$BaseOU"
    $groupName       = "SG-$Dept-Staff" 
    $targetOU        = "OU=$Dept,OU=Staff,$BaseOU"
    
    # Safety Check: Build Group if missing (Skipped if Step 2 ran successfully)
    if (-not (Get-ADGroup -Filter "Name -eq '$groupName'")) {
        New-ADGroup -Name $groupName -SamAccountName $groupName -GroupScope Global -GroupCategory Security -Path $TargetGroupOU
        Write-Host "Created missing group: $groupName inside $TargetGroupOU" -ForegroundColor Magenta
    }

    # Provision User Parameters
    $password = ConvertTo-SecureString "InitPass2026!Enterprise" -AsPlainText -Force
    $userParams = @{
        GivenName             = $user.firstname
        Surname               = $user.lastname
        SamAccountName         = $user.username
        UserPrincipalName     = $user.UPN
        Department            = $Dept
        Title                 = $user.title
        Path                  = $targetOU
        AccountPassword       = $password
        Enabled               = $true
        ChangePasswordAtLogon = $true
        Name                  = "$($user.firstname) $($user.lastname)"
    }
    
    # Verify and deploy user
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.username)'")) {
        New-ADUser @userParams
        Add-ADGroupMember -Identity $groupName -Members $user.username
        Write-Host "Successfully Provisioned & Grouped: $($user.username) -> $groupName" -ForegroundColor Green
    } else {
        Write-Host "User $($user.username) already exists. Skipping creation." -ForegroundColor Yellow
    }
}
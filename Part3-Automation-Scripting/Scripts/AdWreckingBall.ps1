# 1. Target the top-level OU path
$TargetOU = "OU=Prod_Enterprise,$( (Get-ADDomain).DistinguishedName )"

# 2. Strip protection from the TOP-LEVEL folder explicitly
Set-ADOrganizationalUnit -Identity $TargetOU -ProtectedFromAccidentalDeletion $false

# 3. Strip protection from all nested sub-OUs underneath it
Get-ADOrganizationalUnit -Filter "DistinguishedName -like '*$TargetOU'" | 
    Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false

# 4. Wipe out the entire tree and everything inside it
Remove-ADOrganizationalUnit -Identity $TargetOU -Recursive -Confirm:$false

Write-Host "Prod_Enterprise has been completely cleared!" -ForegroundColor Cyan
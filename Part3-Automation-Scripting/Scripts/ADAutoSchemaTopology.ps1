Import-Module ActiveDirectory

$DomainDN       = (Get-ADDomain).DistinguishedName
$TopLevelOUName = "Prod_Enterprise"
$TopLevelPath   = "OU=$TopLevelOUName,$DomainDN"

$SubOUs       = @("Admins", "Groups", "Workstations", "Servers", "Staff")
$Departments  = @("IT", "HR", "Sales", "Finance", "Engineering")

# 1. Ensure Top-Level OU Exists
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$TopLevelOUName'")) {
    New-ADOrganizationalUnit -Name $TopLevelOUName -Path $DomainDN -ProtectedFromAccidentalDeletion $true
    Write-Host "Created Top-Level OU: $TopLevelOUName" -ForegroundColor Cyan
}

# 2. Ensure Core Sub-OUs Exist
foreach ($OU in $SubOUs) {
    $TargetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" | Where-Object { $_.DistinguishedName -like "*$TopLevelPath" }
    if (-not $TargetOU) {
        New-ADOrganizationalUnit -Name $OU -Path $TopLevelPath -ProtectedFromAccidentalDeletion $true
        Write-Host "Created Core Sub-OU: $OU" -ForegroundColor Green
    }
}

# 3. Create Departmental Sub-Containers and Security Groups
$StaffPath        = "OU=Staff,$TopLevelPath"
$WorkstationsPath = "OU=Workstations,$TopLevelPath"
$GroupsPath       = "OU=Groups,$TopLevelPath"

foreach ($Dept in $Departments) {
    # Create Staff User Folders (e.g., OU=HR,OU=Staff,OU=Prod_Enterprise...)
    $TargetStaff = Get-ADOrganizationalUnit -Filter "Name -eq '$Dept'" | Where-Object { $_.DistinguishedName -like "*$StaffPath" }
    if (-not $TargetStaff) {
        New-ADOrganizationalUnit -Name $Dept -Path $StaffPath -ProtectedFromAccidentalDeletion $true
        Write-Host "Created Staff Sub-OU: $Dept" -ForegroundColor Green
    }

    # Create Workstation Computer Folders (e.g., OU=HR-Workstations,OU=Workstations...)
    $TargetWork = Get-ADOrganizationalUnit -Filter "Name -eq '$Dept-Workstations'" | Where-Object { $_.DistinguishedName -like "*$WorkstationsPath" }
    if (-not $TargetWork) {
        New-ADOrganizationalUnit -Name "$Dept-Workstations" -Path $WorkstationsPath -ProtectedFromAccidentalDeletion $true
        Write-Host "Created Workstations Sub-OU: $Dept-Workstations" -ForegroundColor Green
    }

    # Create Security Group Folders/OUs (e.g., OU=HR-Groups,OU=Groups...)
    $TargetGroupOUPath = "OU=$Dept-Groups,$GroupsPath"
    $TargetGroupOU = Get-ADOrganizationalUnit -Filter "Name -eq '$Dept-Groups'" | Where-Object { $_.DistinguishedName -like "*$GroupsPath" }
    if (-not $TargetGroupOU) {
        New-ADOrganizationalUnit -Name "$Dept-Groups" -Path $GroupsPath -ProtectedFromAccidentalDeletion $true
        Write-Host "Created Groups Sub-OU: $Dept-Groups" -ForegroundColor Green
    }

    # Create the actual Security Group OBJECT inside that new folder (e.g., SG-HR-Staff)
    $ExpectedGroupName = "SG-$Dept-Staff"
    if (-not (Get-ADGroup -Filter "Name -eq '$ExpectedGroupName'")) {
        New-ADGroup -Name $ExpectedGroupName -SamAccountName $ExpectedGroupName -GroupScope Global -GroupCategory Security -Path $TargetGroupOUPath
        Write-Host "--> Created Security Group: $ExpectedGroupName" -ForegroundColor Cyan
    }
}

Write-Host "Infrastructure build complete!" -ForegroundColor Green

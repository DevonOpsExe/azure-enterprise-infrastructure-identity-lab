Import-Module GroupPolicy
Import-Module ActiveDirectory

$DomainDN   = (Get-ADDomain).DistinguishedName
$DomainGUID = (Get-ADDomain).ObjectGUID.Guid
$GPOName    = "Sec_Advanced_Auditing"

# 1. Get the Unique ID (GUID) of your GPO
$GPO = Get-GPO -Name $GPOName
$GPOGuid = $GPO.Id

# 2. Map out the path to the SYSVOL share where GPO files live
$SysvolPath = "\\localhost\SYSVOL\$DomainDN\Policies\{$GPOGuid}\Machine\Microsoft\Windows NT\Audit"

# Create the hidden directories if they don't exist yet
if (-not (Test-Path $SysvolPath)) {
    New-Item -ItemType Directory -Path $SysvolPath -Force | Out-Null
}

# 3. Generate the native Windows CSV formatting string for Advanced Auditing
# This explicitly enforces Success & Failure for Logon (Subcategory GUID: 0cce9215-...)
# and Process Creation (Subcategory GUID: 0cce9212-...)
$AuditCSVContent = @"
System,System,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting
Machine,Logon/Logoff,Logon,{0cce9215-69ae-11d9-bed3-505054503030},Success and Failure,None
Machine,Detailed Tracking,Process Creation,{0cce9212-69ae-11d9-bed3-505054503030},Success,None
"@

# Write the security file directly into the GPO template template
$AuditCSVContent | Out-File -FilePath "$SysvolPath\audit.csv" -Encoding ascii -Force

# 4. Enforce Command Line Logging in Process Creation via Registry (This part stays in the registry hive)
Set-GPRegistryValue -Name $GPOName `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -ValueName "ProcessCreationIncludeCmdLine_Output" `
    -Type DWord `
    -Value 1

# Enforce Security Option to prioritize Advanced Auditing
Set-GPRegistryValue -Name $GPOName `
    -Key "HKLM\System\CurrentControlSet\Control\Lsa" `
    -ValueName "SCForceOption" `
    -Type DWord `
    -Value 1

Write-Host "Successfully rewrote GPO template files using native Security CSV formatting!" -ForegroundColor Green
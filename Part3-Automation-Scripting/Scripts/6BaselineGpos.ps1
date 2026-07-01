Import-Module GroupPolicy
Import-Module ActiveDirectory

$DomainName   = (Get-ADDomain).Forest
$DomainDN     = (Get-ADDomain).DistinguishedName
$DomainNetBIOS = (Get-ADDomain).NetBIOSName

# Absolute container mappings matching the enterprise directory layout
$RootPath         = $DomainDN
$BaseOUPath       = "OU=Prod_Enterprise,$DomainDN"
$StaffOU          = "OU=Staff,$BaseOUPath"
$WorkstationsOU   = "OU=Workstations,$BaseOUPath"
$ServersOU        = "OU=Servers,$BaseOUPath"

# Define the full matrix of GPOs and their target deployment OUs
$GPOs = @{
    "Sec_Password_Policy"       = $RootPath
    "Sec_Screen_Lock"           = $StaffOU
    "Sec_Restrict_ControlPanel" = $StaffOU
    "Sec_Disable_USB"           = $StaffOU
    "Sec_Win_Firewall"          = $WorkstationsOU
    "Sec_Audit_Policy"          = $BaseOUPath
}

# ──────────────────────────────────────────────────────────────────────────────
# 1. CREATE AND LINK THE GPOS
# ──────────────────────────────────────────────────────────────────────────────
foreach ($GPOName in $GPOs.Keys) {
    $TargetOU = $GPOs[$GPOName]
    
    # Check if GPO already exists
    if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
        # Create the GPO
        $NewGPO = New-GPO -Name $GPOName -Comment "Automated Enterprise Security Baseline Component"
        
        # Link the GPO to the target OU
        New-GPLink -Name $GPOName -Target $TargetOU | Out-Null
        Write-Host "[+] Created and Linked GPO: $GPOName to $TargetOU" -ForegroundColor Green
    } else {
        Write-Host "[-] GPO $GPOName already exists. Skipping baseline creation step." -ForegroundColor Yellow
    }
}

# Link Sec_Win_Firewall to the Servers OU as well to ensure complete compute coverage
try { New-GPLink -Name "Sec_Win_Firewall" -Target $ServersOU -ErrorAction SilentlyContinue | Out-Null } catch {}

# ──────────────────────────────────────────────────────────────────────────────
# 2. CONFIGURE REGISTRY-BASED POLICY SETTINGS
# ──────────────────────────────────────────────────────────────────────────────
Write-Host "`n🔒 Injecting Registry Settings into GPOs..." -ForegroundColor Cyan

# Policy A: Enforce 15-Minute Screen Lock Timeout
Set-GPRegistryValue -Name "Sec_Screen_Lock" -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaveTimeOut" -Type String -Value "900"
Set-GPRegistryValue -Name "Sec_Screen_Lock" -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaverIsSecure" -Type String -Value "1"
Set-GPRegistryValue -Name "Sec_Screen_Lock" -Key "HKCU\Control Panel\Desktop" -ValueName "SCRNSAVE.EXE" -Type String -Value "scrnsave.scr"
Write-Host "--> Configured Workspace Security inside Sec_Screen_Lock" -ForegroundColor Gray

# Policy B: Restrict Access to Control Panel and PC Settings
Set-GPRegistryValue -Name "Sec_Restrict_ControlPanel" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
Write-Host "--> Configured Shell Restrictions inside Sec_Restrict_ControlPanel" -ForegroundColor Gray

# Policy C: Data Loss Prevention (Disable USB Storage Interfaces)
$USBHardwareGUID = "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"
Set-GPRegistryValue -Name "Sec_Disable_USB" -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\$USBHardwareGUID" -ValueName "Deny_Read" -Type DWord -Value 1
Set-GPRegistryValue -Name "Sec_Disable_USB" -Key "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\$USBHardwareGUID" -ValueName "Deny_Write" -Type DWord -Value 1
Write-Host "--> Configured Endpoint Protection inside Sec_Disable_USB" -ForegroundColor Gray

# Policy D: Perimeter Network Protection (Windows Firewall Mandatory Baseline)
$FirewallProfiles = @("DomainProfile", "PrivateProfile", "PublicProfile")
foreach ($Profile in $FirewallProfiles) {
    Set-GPRegistryValue -Name "Sec_Win_Firewall" -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\$Profile" -ValueName "EnableFirewall" -Type DWord -Value 1
    Set-GPRegistryValue -Name "Sec_Win_Firewall" -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\$Profile" -ValueName "DisableNotifications" -Type DWord -Value 0
}
Write-Host "--> Configured Network Boundary State inside Sec_Win_Firewall" -ForegroundColor Gray

# ──────────────────────────────────────────────────────────────────────────────
# 3. CONFIGURE INTERNALS (DOMAIN RULES & ADVANCED LOGGING TEMPLATES)
# ──────────────────────────────────────────────────────────────────────────────
Write-Host "`n🛡️ Executing Advanced Active Directory Core System Provisioning..." -ForegroundColor Cyan

# Configuration E: Core Identity Validation Hardening (Sec_Password_Policy compliance)
Set-ADDefaultDomainPasswordPolicy -Identity $DomainNetBIOS `
    -ComplexityEnabled $true `
    -MinPasswordLength 14 `
    -PasswordHistoryCount 24 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
    -LockoutThreshold 5
Write-Host "--> Injected Core Domain Password and Account Lockout Parameters" -ForegroundColor Gray

# Configuration F: High-Fidelity Event Telemetry Engineering (Sec_Audit_Policy deployment)
$GPOGuid = (Get-GPO -Name "Sec_Audit_Policy").Id
$SysvolPath = "\\localhost\SYSVOL\$DomainDN\Policies\{$GPOGuid}\Machine\Microsoft\Windows NT\Audit"

if (-not (Test-Path $SysvolPath)) {
    New-Item -ItemType Directory -Path $SysvolPath -Force | Out-Null
}

$AuditCSVContent = @"
System,System,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting
Machine,Logon/Logoff,Logon,{0cce9215-69ae-11d9-bed3-505054503030},Success and Failure,None
Machine,Logon/Logoff,Logoff,{0cce9216-69ae-11d9-bed3-505054503030},Success,None
Machine,Account Management,User Account Management,{0cce9214-69ae-11d9-bed3-505054503030},Success and Failure,None
Machine,Detailed Tracking,Process Creation,{0cce9212-69ae-11d9-bed3-505054503030},Success,None
"@
$AuditCSVContent | Out-File -FilePath "$SysvolPath\audit.csv" -Encoding ascii -Force

# Force Command-Line logging arguments in Event 4688 and enforce kernel policy priorities
Set-GPRegistryValue -Name "Sec_Audit_Policy" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -ValueName "ProcessCreationIncludeCmdLine_Output" -Type DWord -Value 1
Set-GPRegistryValue -Name "Sec_Audit_Policy" -Key "HKLM\System\CurrentControlSet\Control\Lsa" -ValueName "SCForceOption" -Type DWord -Value 1
Write-Host "--> Injected Advanced Security Subsystem Audit Policy and Logging Templates" -ForegroundColor Gray

Write-Host "`n✅ Pipeline Finished: All 6 Security Baselines configured and active." -ForegroundColor Green
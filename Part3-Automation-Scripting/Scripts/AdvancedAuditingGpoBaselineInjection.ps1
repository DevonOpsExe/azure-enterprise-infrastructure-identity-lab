Import-Module GroupPolicy
Import-Module ActiveDirectory

$DomainDN   = (Get-ADDomain).DistinguishedName
$BaseOUPath = "OU=Prod_Enterprise,$DomainDN"
$GPOName    = "Sec_Advanced_Auditing"

# 1. Idempotent GPO Provisioning and Linking
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    $NewGPO = New-GPO -Name $GPOName -Comment "Automated High-Fidelity Security Auditing Baseline"
    New-GPLink -Name $GPOName -Target $BaseOUPath
    Write-Host "Created and Linked GPO: $GPOName to $BaseOUPath" -ForegroundColor Green
} else {
    Write-Host "GPO $GPOName already exists. Skipping creation." -ForegroundColor Yellow
}

# 2. Configure Advanced Audit Policy Settings (Registry-Based)
# Enforce Event ID 4624/4625 (Success & Failure)
Set-GPRegistryValue -Name $GPOName `
    -Key "HKLM\System\CurrentControlSet\Control\Lsa" `
    -ValueName "AuditLogonEvents" `
    -Type DWord `
    -Value 3

# Enforce Event ID 4688 (Process Creation with Command-Line Logging Enabled)
Set-GPRegistryValue -Name $GPOName `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -ValueName "ProcessCreationIncludeCmdLine_Output" `
    -Type DWord `
    -Value 1

# Force Windows to prioritize Advanced Auditing over legacy auditing policies
Set-GPRegistryValue -Name $GPOName `
    -Key "HKLM\System\CurrentControlSet\Control\Lsa" `
    -ValueName "SCForceOption" `
    -Type DWord `
    -Value 1

Write-Host "Advanced Security Auditing baseline injected successfully!" -ForegroundColor Cyan
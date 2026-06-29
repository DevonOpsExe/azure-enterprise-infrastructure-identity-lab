# Lab 3: Enterprise Automation & Scripting with PowerShell

## 📌 Project Overview
With the cloud network infrastructure ([Lab 1](../Part1-Secure-Azure-Networking)) and Active Directory identity plane ([Lab 2](../Part2-Active-Directory)) successfully deployed, this final phase focuses on operational efficiency, scalability, and DevOps methodologies. This project documents the development and execution of custom PowerShell scripting to automate bulk user provisioning, lifecycle management, and security auditing within the `lab.local` domain.

---

## 🎯 Objectives
* Eliminate manual administrative overhead by automating mass user onboarding.
* Develop a robust PowerShell script that parses external data sources (CSV) and dynamically provisions accounts.
* Enforce standardized naming conventions, secure random password generation, and automatic OU placement.
* Build an automated auditing utility to detect stale or inactive domain accounts, enhancing the environment's security posture.


---

## 🛠️ Automation Logic & Flow
 Active Directory Schema automation
 
 *
 *
 *

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/62100731-4039-4666-bcb7-08545a3bcaac" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/391c1f68-f6c9-4d5e-a987-e01edfa584e8" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/dde7cd21-87bf-4ac0-b104-9c7fe7344a57" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>
 











* Instead of manually clicking through Active Directory Users and Computers (ADUC) to create hundreds of corporate accounts, the automation pipeline reads raw data, sanitizes it, maps it to the target OU architecture, and provisions the assets programmatically.

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/4f11df3f-08c9-4826-a3b2-d2a2e789719f" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/9c8081ca-d386-4cca-8d7b-c297077103eb" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/38445a02-cdf7-42fb-8b34-46b099c29663" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

```text
┌─────────────────┐       ┌────────────────────────┐       ┌─────────────────────────┐
│  Employees.csv  │ ────► │ Custom Onboarding Script│ ────► │  Active Directory DS    │
│  (Raw HR Data)  │       │ (Sanitation & Logic)   │       │ (Structured OUs & Users)│
└─────────────────┘       └────────────────────────┘       └─────────────────────────┘
```

---

## 🛡️ Group Policy Object (GPO) Design & Automation

To enforce security compliance and restrict the attack surface across the enterprise, a Group Policy baseline was established. Rather than manually configuring policies through the Group Policy Management Console (GPMC) GUI, deployment was completely automated using the cloud-native `GroupPolicy` PowerShell module.

### 📊 Group Policy Inheritance & Architecture

Policies are linked strategically to enforce user-specific constraints on general staff while preventing configuration drift or lockout on administrative and domain controller accounts.

```text
lab.local (Domain Root)
   └── 🔗 Global Account Policies (Default Domain Policy)
       │
       └── 🏢 Prod_Enterprise
           ├── 📁 Staff [User Context]
           │   ├── 🔗 Sec_Screen_Lock (Inactivity Timeout)
           │   └── 🔗 Sec_Restrict_ControlPanel (Environment Lockdown)
           │       ├── 📁 IT / HR / Sales / Finance / Engineering
           │
           └── 📁 Workstations [Computer Context]
               └── 💻 IT-Workstations / HR-Workstations / ...
```
---

### 🔎 Advanced Security Auditing & SOC Visibility

To transform the environment from a standard operational domain into a security-monitoring platform capable of feeding a SIEM (Security Information and Event Management), an Advanced Security Audit Policy baseline was implemented. 

By enforcing advanced auditing subcategories, the environment generates high-fidelity Event IDs crucial for threat hunting, compliance auditing, and detecting living-off-the-land techniques.

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/4f11df3f-08c9-4826-a3b2-d2a2e789719f" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/9c8081ca-d386-4cca-8d7b-c297077103eb" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/38445a02-cdf7-42fb-8b34-46b099c29663" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

```text
lab.local (Domain Root)
   └── 🏢 Prod_Enterprise
       ├── 🔗 Sec_Advanced_Auditing (Linked at root for global visibility)
       │   ├── 📁 Staff (Audits authentication anomalies)
       │   └── 📁 Workstations (Audits local exploitation/process creation)
```
---
---
---

# Lab 3: Enterprise Automation & Scripting with PowerShell

## 📌 Project Overview
With the cloud network infrastructure ([Lab 1](../Part1-Secure-Azure-Networking)) and Active Directory identity plane ([Lab 2](../Part2-Active-Directory)) successfully deployed within a resource-constrained cloud framework (Microsoft Azure via Google Chromebook), this final phase focuses on operational efficiency, scalability, and DevOps methodologies. 

By prioritizing Infrastructure-as-Code (IaC) principles, the entire Active Directory lifecycle—from tree topology provisioning to bulk identity ingestion and Group Policy hardening—was engineered utilizing modular, idempotent PowerShell scripting.

The lab is split into three phases:
1. **Infrastructure & Lifecycle Management:** Programmatic destruction and generation of standard enterprise containers.
2. **Automated Identity Provisioning:** Dynamic bulk ingestion and segmentation of target user objects mapped to department security groups.
3. **Enterprise Hardening & SOC Visibility:** Implementation of strict security baselines, environmental restrictions, and high-fidelity event auditing.

---

## 🎯 Objectives
* Eliminate manual administrative overhead by automating mass user onboarding using production-level directory engineering frameworks.
* Develop a robust PowerShell script that parses external data sources (CSV) and dynamically provisions accounts.
* Enforce standardized naming conventions, secure random password generation, and automatic OU placement.
* Build an automated auditing utility to detect stale or inactive domain accounts, enhancing the environment's security posture.
* Implement advanced kernel-level logging architecture to ensure infrastructure visibility for downstream SIEM integration.

---

## 🏗️ Enterprise Architecture & Directory Topology

The logical structure of the `lab.local` forest utilizes a deeply segmented, inheritance-optimized layout designed to prevent privilege escalation and facilitate modular Group Policy targeting.

```text
lab.local (Domain Root)
│   └── 🔗 Global Account Policies (Default Domain Policy)
│
└── 🏢 Prod_Enterprise
    ├── 🔗 Sec_Advanced_Auditing (High-Fidelity Event Logging)
    │
    ├── 📁 Admins
    │
    ├── 📁 Groups
    │   ├── 📁 IT-Groups ─── 👥 SG-IT-Staff
    │   ├── 📁 HR-Groups ─── 👥 SG-HR-Staff
    │   └── [Sales / Finance / Engineering Groups]
    │
    ├── 📁 Workstations
    │   ├── 💻 IT-Workstations
    │   └── [HR / Sales / Finance / Engineering Workstations]
    │
    ├── 📁 Servers
    │
    └── 📁 Staff
        ├── 📁 IT ─── 👤 [Imported IT User Accounts] (Inherits User Restrictions)
        ├── 📁 HR ─── 👤 [Imported HR User Accounts]
        └── [Sales / Finance / Engineering Staff OUs]
```
---

## 🛠️ Automation Logic & Flow

### 📦 Phase 1 & 2: Active Directory Schema Automation & Bulk Ingestion
To eliminate manual administrative overhead, directory cleanup and creation are managed via lifecycle tracking scripts.

* **The Cleanup Engine:** Explicitly targets the parent hierarchy, strips Active Directory's explicit `Deny` rules for deletion (`-ProtectedFromAccidentalDeletion $false`), and executes a bottom-up recursive purge.
* **The Blueprint Builder:** Generates core structural OUs dynamically, maps out the departmental child containers, and provisions baseline security group objects (`SG-$Dept-Staff`) into dedicated, segregated paths.
* **The Ingestion Pipeline:** Instead of manually clicking through Active Directory Users and Computers (ADUC) to create hundreds of corporate accounts, the automation pipeline reads raw data, sanitizes it, maps it to the target OU architecture, and provisions the assets programmatically.

User provisioning is accomplished via a custom provisioning engine that ingests an external raw data payload (`mock_users.csv`). For every entry, the script:
1. Parses corporate department schemas to map target organizational container paths.
2. Programmatically constructs individual user attributes.
3. Generates secure, random-string initial passwords.
4. Forces a password change upon the user's initial interactive session (`ChangePasswordAtLogon = $true`).
5. Automatically binds the live user object directly to its respective department global security group to guarantee seamless authorization profiles.

```text
┌─────────────────┐       ┌────────────────────────┐       ┌─────────────────────────┐
│  Employees.csv  │ ────► │ Custom Onboarding Script│ ────► │  Active Directory DS    │
│  (Raw HR Data)  │       │ (Sanitation & Logic)   │       │ (Structured OUs & Users)│
└─────────────────┘       └────────────────────────┘       └─────────────────────────┘
```
---

## 🛡️ Phase 3: Group Policy Object (GPO) Design & Automation

To enforce security compliance and restrict the attack surface across the enterprise, a Group Policy baseline was established. Rather than manually configuring policies through the Group Policy Management Console (GPMC) GUI, deployment was completely automated using the cloud-native `GroupPolicy` PowerShell module.

### 📊 Group Policy Inheritance & Architecture
Policies are linked strategically to enforce user-specific constraints on general staff while preventing configuration drift or lockout on administrative and domain controller accounts.
```text
lab.local (Domain Root)
   └── 🔗 Global Account Policies (Default Domain Policy)
       │
       └── 🏢 Prod_Enterprise
           ├── 📁 Staff [User Context]
           │   ├── 🔗 Sec_Screen_Lock (Inactivity Timeout)
           │   └── 🔗 Sec_Restrict_ControlPanel (Environment Lockdown)
           │       ├── 📁 IT / HR / Sales / Finance / Engineering
           │
           └── 📁 Workstations [Computer Context]
               └── 💻 IT-Workstations / HR-Workstations / ...
```
### 🛡️ Core Security GPOs to Implement

For an enterprise-grade lab environment, here are the standard baseline policies you'll want to create:

| GPO Name | Target OU | What It Enforces (The Security Goal) |
| :--- | :--- | :--- |
| **Sec_Password_Policy** | `lab.local (Root)` | Standardizes length (e.g., 14+ characters), complexity, and lockouts across the whole domain. |
| **Sec_Screen_Lock** | `Staff` | Enforces a 15-minute inactivity timeout that locks the workstation screen to prevent physical tampering. |
| **Sec_Restrict_ControlPanel** | `Staff (or specific depts)` | Blocks non-admin staff from accessing the Control Panel or Windows Settings to stop unauthorized system tweaks. |
| **Sec_Disable_USB** | `Staff` | Blocks removable storage drives to prevent data exfiltration and malware introduction (Data Loss Prevention). |
| **Sec_Win_Firewall** | `Workstations & Servers` | Forces the Windows Defender Firewall to stay On for all profiles and manages inbound/outbound rules centrally. |
| **Sec_Audit_Policy** | `Prod_Enterprise (Root)` | Enables advanced logging (success/failure for logons, file access, account changes) so your future SIEM/SOC lab actually has logs to analyze! |

### 📊 Enterprise Infrastructure Security Matrix

The following table outlines the comprehensive security architecture programmatically deployed across the active directory forest via the automation pipeline:

### 📊 Enterprise Infrastructure Security Matrix

The following table outlines the comprehensive security architecture programmatically deployed across the Active Directory forest via the automation pipeline:

| GPO / Policy Name | Scope Context | Target OU / Container | Technical Configuration Mechanism & Registry Path | Action / Defensive Security Goal |
| :--- | :--- | :--- | :--- | :--- |
| **Sec_Password_Policy** | Domain Level | `lab.local` (Root) | Direct NTDS Database Modification <br> `Set-ADDomainPasswordPolicy` | Enforces **14+ character min length**, 24 password history, and a **5-strike lockout threshold** for 30 minutes to mitigate brute-force and dictionary attacks. |
| **Sec_Screen_Lock** | User Context | `OU=Staff` | `HKCU\Control Panel\Desktop` <br> ── `ScreenSaveTimeOut` = `"900"` <br> ── `ScreenSaverIsSecure` = `"1"` <br> ── `SCRNSAVE.EXE` = `"scrnsave.scr"` | Enforces a **15-minute (900s) inactivity timeout**, flags the screensaver as secure, and forces password re-authentication to prevent physical tampering. |
| **Sec_Restrict_ControlPanel** | User Context | `OU=Staff` | `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` <br> ── `NoControlPanel` = `1` (DWord) | Disables access to the Control Panel and Windows Settings app to prevent standard users from making unauthorized system tweaks. |
| **Sec_Disable_USB** | Computer Context | `OU=Staff` | `HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}` <br> ── `Deny_Read` = `1` (DWord) <br> ── `Deny_Write` = `1` (DWord) | **Data Loss Prevention (DLP):** Targets the mass storage device hardware GUID to completely deny both Read and Write permissions on USB external drives. |
| **Sec_Win_Firewall** | Computer Context | `OU=Workstations` & `OU=Servers` | `HKLM\Software\Policies\Microsoft\WindowsFirewall\[Profile]` <br> *(Loops Domain, Private, Public Profiles)* <br> ── `EnableFirewall` = `1` (DWord) <br> ── `DisableNotifications` = `0` (DWord) | Centrally forces the **Windows Defender Firewall state to ON** across all three major network profiles and blocks user override notifications. |
| **Sec_Audit_Policy** | Subsystem / Kernel | `OU=Prod_Enterprise` | **SYSVOL Ingestion:** `\Policies\{GUID}\Machine\Microsoft\Windows NT\Audit\audit.csv` <br><br> **Registry Priority Keys:** <br> ── `HKLM\...\Policies\System\Audit\ProcessCreationIncludeCmdLine_Output` = `1` <br> ── `HKLM\System\CurrentControlSet\Control\Lsa\SCForceOption` = `1` | **SOC Visibility:** Generates high-fidelity event logs for **Logon/Logoff (4624/4625)**, **Account Management**, and **Process Creation (4688)** with full command-line logging enabled for threat hunting. |

---

### 🔍 Pipeline Execution Workflow

The automation framework systematically provisions controls through the following logical phases:

```text
[Execute Script]
       │
       ▼
1. Discovery ───────► Queries Active Directory for Forest, NetBIOS, and Domain DN strings.
       │
       ▼
2. Provisioning ────► Iterates through a hash table to build and link empty GPOs idempotently.
       │
       ▼
3. Registry Engine ─► Broadly injects HKLM/HKCU configurations for Screen Locks, USB Blocks, and Firewalls.
       │
       ▼
4. AD Database ─────► Direct modification of core domain identity requirements (Passwords/Lockouts).
       │
       ▼
5. SYSVOL Ingestion ──► Generates and forces low-level advanced audit auditing CSV templates into the system share.

```

> 💡 **Note:** Manual configuration controls were also deployed to remediate perimeter risk vectors, including account lockout policies, strict password histories, explicit network drive mapping, hardware-level USB media bans, corporate workspace canvas delivery, and the mitigation of Link-Local Multicast Name Resolution (LLMNR) to prevent local spoofing attacks.

---

### 🔎 Advanced Security Auditing & SOC Visibility

To transform the environment from a standard operational domain into a security-monitoring platform capable of feeding a SIEM (Security Information and Event Management) system, an **Advanced Security Audit Policy** baseline was implemented.

By enforcing advanced auditing subcategories, the environment generates high-fidelity Event IDs crucial for threat hunting, compliance auditing, and detecting living-off-the-land techniques. Because these security subsystem policies alter kernel behaviors directly, validation must be queried using the system `auditpol` engine rather than standard `gpresult` wrappers.

```text
lab.local (Domain Root)
   └── 🏢 Prod_Enterprise
       ├── 🔗 Sec_Advanced_Auditing (Linked at root for global visibility)
       │   ├── 📁 Staff (Audits authentication anomalies)
       │   └── 📁 Workstations (Audits local exploitation/process creation)
```

#### 📊 Enforced Security Log Events

| Log Category | Targeting Objective | Target Event IDs | Security Purpose |
| :--- | :--- | :--- | :--- |
| **Audit Logon / Logoff** | Success & Failure | `4624`, `4625` | Detects brute-force vectors, lateral movement, and unauthorized interactive sessions. |
| **Detailed Tracking** | Process Creation | `4688` | Captures the execution of programs and includes command-line logging to analyze malicious scripts (e.g., PowerShell/CMD attacks). |
| **Audit Policy Override** | SCForceOption | N/A | Explicitly instructs the Windows kernel to ignore legacy audit categories in favor of strict advanced criteria settings. |
---
#### 🛠️ Infrastructure-as-Code Auditing Deployment Script

Because modern Windows endpoints protect security policy parameters strictly, this baseline was programmatically injected straight into the native `audit.csv` templates inside the GPO's SYSVOL folder hierarchy to guarantee successful downstream execution:
```powershell
Import-Module GroupPolicy
Import-Module ActiveDirectory

$DomainDN   = (Get-ADDomain).DistinguishedName
$GPOName    = "Sec_Advanced_Auditing"
$BaseOUPath = "OU=Prod_Enterprise,$DomainDN"

# 1. Idempotent GPO Provisioning and Linking
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    $NewGPO = New-GPO -Name $GPOName -Comment "Automated High-Fidelity Security Auditing Baseline"
    New-GPLink -Name $GPOName -Target $BaseOUPath
    Write-Host "Created and Linked GPO: $GPOName" -ForegroundColor Green
}

# 2. Map target GPO file paths inside the SYSVOL share
$GPOGuid = (Get-GPO -Name $GPOName).Id
$SysvolPath = "\\localhost\SYSVOL\$DomainDN\Policies\{$GPOGuid}\Machine\Microsoft\Windows NT\Audit"

if (-not (Test-Path $SysvolPath)) {
    New-Item -ItemType Directory -Path $SysvolPath -Force | Out-Null
}

# 3. Formulate the Native Windows Security Auditing Template Payload
$AuditCSVContent = @"
System,System,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting
Machine,Logon/Logoff,Logon,{0cce9215-69ae-11d9-bed3-505054503030},Success and Failure,None
Machine,Detailed Tracking,Process Creation,{0cce9212-69ae-11d9-bed3-505054503030},Success,None
"@

$AuditCSVContent | Out-File -FilePath "$SysvolPath\audit.csv" -Encoding ascii -Force

# 4. Inject Process Command-Line Argument Logging and Enforce Priorities via Registry
Set-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -ValueName "ProcessCreationIncludeCmdLine_Output" -Type DWord -Value 1
Set-GPRegistryValue -Name $GPOName -Key "HKLM\System\CurrentControlSet\Control\Lsa" -ValueName "SCForceOption" -Type DWord -Value 1

Write-Host "Advanced Security Auditing baseline injected successfully!" -ForegroundColor Cyan
```


---
## 🏆 Key Competencies Demonstrated

* **Infrastructure-as-Code (IaC):** Complete directory provisioning, cleaning, and linking executed programmatically with zero manual mouse clicks.
* **Defensive System Hardening:** Practical implementation of least privilege configurations, administrative boundary containment, physical access limits, and credential validation restrictions.
* **SOC & Threat Hunting Readiness:** Tuning directory log outputs to emit high-fidelity telemetry payloads necessary for analysis inside enterprise SIEM clusters.
* **Cloud Resource Agility:** Optimizing enterprise asset deployments under explicit compute baseline constraints by managing Azure workloads entirely via streamlined cloud architectures.



# Portfolio Project: Automated Enterprise Identity, Infrastructure Hardening, & SOC Telemetry Engineering

## Executive Summary

### Project Overview
This comprehensive portfolio project details the architecture, programmatic deployment, and operational validation of a zero-trust corporate security baseline within a Microsoft Active Directory infrastructure. Engineered entirely within **Microsoft Azure** to overcome local physical resource and hardware constraints, this environment mirrors modern, cloud-hosted enterprise operational frameworks.

The core objective of this project was to transition an unmanaged, default out-of-the-box infrastructure footprint into a highly secure, automated network environment. By leveraging infrastructure-as-code principles and advanced PowerShell orchestration, the project completely eliminates manual administrative overhead while engineering the rigorous security logging pipelines necessary to feed downstream SIEM/SOC analytics engines.
---
## Multi-Phase Lab Breakdown
This master implementation was executed across **three distinct, sequential labs**, each addressing a critical pillar of enterprise systems security engineering:
### 1: Network Infrastructure Architecture
Because the lab was engineered inside a cloud-native tenant, a rigid network topology was mapped out first to establish isolated broadcast domains and control traffic flow:
* **Virtual Network (VNet) Topology:** Provisioned a dedicated Azure Virtual Network (`Enterprise-VNet`) configured with a private Class B address space (**10.0.0.0/16**). This space provides ample allocation for corporate assets while maintaining complete isolation from external networks.
* **Subnet Segmentation:** Split the VNet into structured subnets to segregate compute resources by tier and enforce network-layer boundaries:
  * `Identity-Subnet` (**10.0.1.0/26**): Dedicated strictly to Domain Controllers and identity management systems.
  * `Endpoint-Subnet` (**10.0.2.0/24**): Dedicated to client workstations (IT, HR, Sales, etc.).
  * `Server-Subnet` (**10.0.0.0/24**): Dedicated to internal production application servers.
* **DNS Plane Routing:** Overrode the default Azure-provided DNS routing. The `Enterprise-VNet` was statically configured to route all internal DNS resolution directly to the Domain Controller's private IP (`10.0.0.4`). This change is fundamental; it ensures that client workstations provisioned in downstream phases can successfully discover the domain, handle Kerberos tickets, and process Group Policy updates.
* **Network Security Groups (NSGs):** Implemented strict Azure NSG rules at the subnet boundaries to act as a stateless perimeter firewall. This limits external RDP management access exclusively to verified administrator IPs and restricts inter-subnet traffic to essential Active Directory communication protocols (e.g., LDAPS, Kerberos, DNS, SMB).
---
### 📁 2:Windows Server Provisioning & Active Directory Core Installation
Following the network infrastructure layout, the primary identity engine was built by deploying a virtualized Windows Server instance and promoting it to an enterprise Root Domain Controller. This phase established the centralized identity plane, Kerberos authentication realm, and internal DNS root for the entire virtual network.

### 2.1 Compute Provisioning & Core OS Initialization
* **Instance Deployment:** A virtual machine running **Windows Server 2022 Datacenter** was provisioned inside the `Identity-Subnet` (`10.0.0.0/24`) with a statically assigned private IP address of **10.0.0.4**.
* **Host Hardening:** Prior to role promotion, initial operating system cleanup was performed. The local administrator account was secured with an enterprise-grade passphrase, automated Windows updates were initialized, and the host NetBIOS name was standardized to `lab-vm`.

### 2.2 Programmatic Role Installation (ADDS & DNS)
To ensure deployment efficiency and repeatability, the Active Directory Domain Services (AD-DS) role and the authoritative DNS server role were installed concurrently via an elevated PowerShell session:
```powershell
# Install the core Active Directory and DNS binaries on the local host
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools
```
### 2.3 Forest Promotion & Directory Database Placement
The server was promoted to the first Root Domain Controller of a brand new Active Directory Forest named `lab.local`.
### 2.4 Authoritative DNS Server Post-Configuration
Once the forest feature wrapper initialized and forced a system reboot, post-deployment optimization was completed on the integrated DNS layer:

* **Active Directory Integrated Zones:** Configured the `lab.local` zone as an Active Directory-integrated primary zone, ensuring that zone data is securely replicated alongside standard NTDS directory data across all future domain controllers.
* **Forward Lookup & Reverse Lookup Zones:** Verified the automatic generation of Forward Lookup Zones for domain locator services (SRV records) and programmatically initialized a Reverse Lookup Zone for the `10.0.0.0/16` subnet space to support absolute Pointer (PTR) record resolution.
* **Upstream Forwarders:** Configured secure, public upstream forwarders (e.g., Cloudflare `1.1.1.1` / Google `8.8.8.8`) at the server level. This guarantees that internal domain assets can resolve external web resources safely, while routing internal `*.lab.local` traffic strictly inside the private virtual network.

### 📁 3: Active Directory Topology & Automated Identity Ingestion

The foundational phase established a scalable, role-based container hierarchy to cleanly isolate and govern corporate assets within the pre-configured network subnets.
* **Structural OU Architecture:** Engineered a tiered Organizational Unit (OU) design under a root corporate container (`Prod_Enterprise`). To strictly limit lateral movement paths, user identity containers (`Staff`) were completely segregated from compute endpoints (`Workstations`) and infrastructure assets (`Servers`).
* **Automated Identity Ingestion:** Rather than relying on manual GUI object creation, a custom PowerShell ingestion framework was developed to automatically parse simulated corporate directories, map sub-departments (IT, HR, Sales, Finance, Engineering), and provision batch identities with standardized security parameters.

### ⚙️ 3.1: Programmatic Security Baseline & GPO Automation
[Lab 2](../Part2-Active-)
To enforce a uniform, non-bypassable security posture across all endpoints and user contexts, a centralized security matrix was engineered and deployed via an idempotent PowerShell orchestration script. The framework programmatically generated and linked six distinct **Group Policy Objects (GPOs)** to achieve immediate environment lockdown.
* **Identity Plane Hardening:** Remediated the Active Directory database directly to mandate a strict **14+ character password minimum length**, a 24-generation password history, and a 5-strike account lockout threshold.
* **Host Boundary Defense:** Centrally locked the Windows Defender Firewall state to "ON" across all network operational profiles (Domain, Private, and Public) while completely disabling standard user override prompts.
* **Endpoint Hardening & DLP:** Deployed storage blocks to disable external mass storage hardware interfaces via registry manipulation, mandated 15-minute secure inactivity desktop timeouts, and banned access to local system configuration panels.

### 🛡️ Lab 3.2: Advanced Logging Telemetry & SIEM/SOC Readiness
The final phase transformed the hardened infrastructure into a data-rich security monitoring ecosystem capable of generating forensic-grade telemetry for threat hunters.
* **SYSVOL Ingestion Pipeline:** Bypassed restrictive OS client policy wrappers by programmatically building and injecting a custom low-level `audit.csv` advanced auditing template directly into the GPO directory structure inside the SYSVOL file share.
* **High-Fidelity Telemetry Generation:** Programmatically activated kernel auditing across critical forensic categories to generate explicit event logs for **Successful/Failed Logons**, Session Logoffs, and Account Management/Privilege Changes.
* **Command-Line Evasion Defense:** Injected registry overrides to enforce complete command-line argument logging within Process Creation logs. This ensures that obfuscated, fileless, or "living-off-the-land" scripting payloads (e.g., malicious PowerShell/CMD execution strings) are exposed in clear text.

---

## 4. Directory Layout Topology

The logical structure of the Active Directory environment following the automated pipeline execution:

```text
lab.local (Domain Root)
 ├── 🔗 Sec_Password_Policy (Enforces global password complexity & lockout baselines)
 │
 └── 🏢 Prod_Enterprise (Enterprise Infrastructure Root)
      ├── 🔗 Sec_Audit_Policy (Enforces high-fidelity logging across all descendant OUs)
      │
      ├── 📁 Staff [User Context]
      │    ├── 🔗 Sec_Screen_Lock (Inactivity Timeout)
      │    ├── 🔗 Sec_Restrict_ControlPanel (Environment Lockdown)
      │    ├── 🔗 Sec_Disable_USB (Data Loss Prevention)
      │    │
      │    └── 📁 Department Sub-OUs
      │         ├── 📁 IT
      │         ├── 📁 HR
      │         ├── 📁 Sales
      │         ├── 📁 Finance
      │         └── 📁 Engineering
      │
      ├── 📁 Workstations [Computer Context]
      │    ├── 🔗 Sec_Win_Firewall (Mandatory host perimeter defense profile)
      │    │
      │    └── 📁 Endpoint Sub-OUs
      │         ├── 💻 IT-Workstations
      │         ├── 💻 HR-Workstations
      │         ├── 💻 Sales-Workstations
      │         ├── 💻 Finance-Workstations
      │         └── 💻 Engineering-Workstations
      │
      └── 📁 Servers [Computer Context]
           └── 🔗 Sec_Win_Firewall (Directly linked to maintain uniform perimeter defense)
```
---
##  Enterprise Infrastructure Security Matrix

The following table outlines the comprehensive security controls programmatically deployed via the automation framework:

| GPO / Policy Name | Scope Context | Target OU / Container | Technical Configuration Mechanism & Registry Path | Action / Defensive Security Goal |
| :--- | :--- | :--- | :--- | :--- |
| **Sec_Password_Policy** | Domain Level | `lab.local` (Root) | Direct NTDS Database Modification <br><br> `Set-ADDefaultDomainPasswordPolicy` | Enforces **14+ character min length**, 24 password history, and a **5-strike lockout threshold** for 30 minutes to mitigate brute-force attacks. |
| **Sec_Screen_Lock** | User Context | `OU=Staff` | `HKCU\Control Panel\Desktop` <br><br> ── `ScreenSaveTimeOut` = `"900"` <br> ── `ScreenSaverIsSecure` = `"1"` <br> ── `SCRNSAVE.EXE` = `"scrnsave.scr"` | Enforces a **15-minute (900s) inactivity timeout**, flags the screensaver as secure, and forces password re-authentication to prevent physical tampering. |
| **Sec_Restrict_ControlPanel** | User Context | `OU=Staff` | `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` <br><br> ── `NoControlPanel` = `1` (DWord) | Disables access to the Control Panel and Windows Settings app to prevent standard users from making unauthorized system tweaks. |
| **Sec_Disable_USB** | Computer Context | `OU=Staff` | `HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}` <br><br> ── `Deny_Read` = `1` (DWord) <br> ── `Deny_Write` = `1` (DWord) | **Data Loss Prevention (DLP):** Targets the mass storage device hardware GUID to completely deny both Read and Write permissions on USB external drives. |
| **Sec_Win_Firewall** | Computer Context | `OU=Workstations` & `OU=Servers` | `HKLM\Software\Policies\Microsoft\WindowsFirewall\[Profile]` <br><br> *(Loops Domain, Private, Public Profiles)* <br> ── `EnableFirewall` = `1` (DWord) <br> ── `DisableNotifications` = `0` (DWord) | Centrally forces the **Windows Defender Firewall state to ON** across all three major network profiles and blocks user override notifications. |
| **Sec_Audit_Policy** | Subsystem / Kernel | `OU=Prod_Enterprise` | **SYSVOL Ingestion:** <br> `\Policies\{GUID}\Machine\Microsoft\Windows NT\Audit\audit.csv` <br><br> **Registry Priority Keys:** <br> ── `HKLM\...\Policies\System\Audit\ProcessCreationIncludeCmdLine_Output` = `1` <br> ── `HKLM\System\CurrentControlSet\Control\Lsa\SCForceOption` = `1` | **SOC Visibility:** Generates high-fidelity event logs for **Logon/Logoff**, **Account Management**, and **Process Creation** with full command-line logging enabled for threat hunting. |

---
## Enforced Security Log Events

| Log Category | Targeting Objective | Target Event IDs | Security Purpose |
| :--- | :--- | :--- | :--- |
| **Audit Logon / Logoff** | Success & Failure | `4624`, `4625`, `4634` | Tracks successful authentication, failed login anomalies (brute-force vectors), lateral movement patterns, and active interactive session durations. |
| **Account Management** | Success & Failure | *Category Level* <br><br> `4720`, `4722`, `4738` | Monitors user account creation, enabling, modifications, and privilege escalations to detect insider threats or persistence mechanisms. |
| **Detailed Tracking** | Process Creation | `4688` | Captures programmatic execution payloads and enforces command-line logging to expose living-off-the-land techniques (e.g., malicious PowerShell/CMD scripts). |
| **Audit Policy Override** | SCForceOption | N/A | Explicitly instructs the Windows kernel to ignore legacy audit categories in favor of strict advanced criteria subsettings, preventing baseline evasion. |

---

## Strategic Outcomes & Architectural Alignment

* **Zero-Trust Baseline Architecture:** Establishes a strict corporate security perimeter that neutralizes common entry-level threat vectors, including physical machine tampering, USB-bound malware introduction, credential harvesting, and brute-force discovery.
* **Defensive Automation Proof-of-Work:** Demonstrates complete mastery over systems automation, registry engineering, and programmatic Active Directory database orchestration without relying on third-party deployment toolsets.
* **Audit Compliance & Visibility:** Aligns the environment's identity and monitoring infrastructure with professional governance standards (such as **CIS Controls** and **NIST 800-53** benchmarks), providing an elite data source for threat hunting, compliance verification, and SIEM monitoring labs.

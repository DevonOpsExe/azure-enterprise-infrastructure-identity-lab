# Lab 2: Hybrid Identity & Active Directory Domain Services (AD DS)

## 📌 Project Overview
Building directly on top of the secure network backbone established in [Lab 1](../Part1-Secure-Azure-Networking), this project shifts focus to enterprise Identity and Access Management (IAM). This phase documents the deployment, promotion, and hardening of a Windows Server Active Directory Domain Services (AD DS) infrastructure within a private subnet, simulating a resilient hybrid identity corporate ecosystem.

---

## 🎯 Objectives
* Provision and configure a Windows Server core instance within a private subnet.
* Promote the server to a Primary Domain Controller (DC) and establish a new AD Forest.
* Design a scalable Organizational Unit (OU) hierarchy reflecting a standard corporate structure.
* Enforce security baselines across the domain using targeted Group Policy Objects (GPOs).
* Configure internal DNS routing and DHCP options within the Azure environment.

---

## 🛠️ Architecture & Components
This lab lives inside the isolated `Identity-Subnet` established in Lab 1. Administrative management is performed exclusively via the secure Jumpbox host.

* **Domain Name:** `enterprise.local` (Simulated Internal Domain)
* **Domain Controller VM:** `DC-01` (Windows Server)
* **IP Allocation:** `10.0.2.4` (Static Private IP)
* **Subnet:** `Identity-Subnet` (`10.0.2.0/24`)

---

## 🚀 Implementation Steps

### Phase 1: Virtual Machine Provisioning & Network Bindings
1. Provisioned a Windows Server virtual machine (`DC-01`) within the `Identity-Subnet`.
2. **Crucial Azure Step:** Changed the VM's private IP allocation from *Dynamic* to *Static* within the Azure portal to ensure the Domain Controller maintains a permanent IP address (`10.0.2.4`).
3. Updated the Azure Virtual Network (VNet) DNS server settings to point directly to `10.0.2.4`, ensuring all future assets joined to the network can locate the Domain Controller for authentication.

### Phase 2: Active Directory Installation & Forest Promotion
1. Leveraged the management Jumpbox to RDP into `DC-01`.
2. Installed the **Active Directory Domain Services** and **DNS Server** roles via Server Manager.
3. Promoted the server to a Domain Controller, creating a new root forest named `enterprise.local`.
4. Configured the Directory Services Restore Mode (DSRM) password and verified successful replication post-reboot.

### Phase 3: Enterprise Organizational Unit (OU) Design
To prepare for scalable user and asset management, a structured OU hierarchy was designed and built to isolate administrative privileges:

```text
enterprise.local (Root)
│
└── 🏢 Enterprise-HQ
    ├── 📁 Groups (Security & Distribution groups)
    ├── 📁 Workstations (Corporate endpoint computer objects)
    ├── 📁 Servers (Member server objects)
    └── 📁 Staff (Standard user accounts)
        ├── 👤 IT-Admin (Delegated administrative staff)
        ├── 👤 Human-Resources
        └── 👤 Finance

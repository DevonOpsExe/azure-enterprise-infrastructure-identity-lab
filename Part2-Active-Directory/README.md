# Lab 2: Identity & Active Directory Domain Services (AD DS) Infrastructure

## 📌 Project Overview
Building directly on top of the secure network backbone established in [Lab 1](../Part1-Secure-Azure-Networking), this project shifts focus to enterprise Identity and Access Management (IAM). This phase documents the deployment, promotion, and hardening of a Windows Server Active Directory Domain Services (AD DS) infrastructure within a private subnet, simulating a resilient, centralized corporate identity ecosystem.

---

## 🎯 Objectives
* Provision and configure a Windows Server core instance within an isolated private subnet.
* Promote the server to a Primary Domain Controller (DC) and establish a new AD Forest.
* Design a scalable Organizational Unit (OU) hierarchy reflecting a standard corporate structure.
* Enforce security baselines across the domain using targeted Group Policy Objects (GPOs).
* Configure internal DNS routing within the Azure environment to support domain discovery.

---

## 🛠️ Architecture & Components
This lab lives inside the isolated `default` subnet established in Lab 1. Inbound network access is strictly locked down by `NSG-Identity`, and administrative management is performed exclusively via secure Azure Bastion proxies or authorized hosts in the management tier.

* **Domain Name:** `lab.local` (Simulated Internal Domain)
* **Domain Controller VM:** `lab-vm` (Windows Server)
* **IP Allocation:** `10.0.0.4` (Static Private IP)
* **Subnet:** `default` (`10.0.0.0/24`)

---

## 🚀 Implementation Steps

### Phase 1: Virtual Machine Provisioning & Network Bindings
1. Provisioned a Windows Server virtual machine (`lab-vm`) directly within the identity zone (`default` subnet).
2. **Crucial Azure Step:** Changed the VM's private IP allocation from *Dynamic* to *Static* within the Azure portal NIC settings to ensure the Domain Controller maintains a permanent network footprint (`10.0.0.4`).
3. Updated the Azure Virtual Network (`Vnet core`) DNS server settings to point directly to `10.0.0.4`, ensuring all future assets joined to the network can seamlessly locate the Domain Controller for domain authentication.

<div align="center">
  <table>
    <tr>
      <td><img src="PASTE_IMAGE_1_URL_HERE" width="100%" alt="Description 1" /></td>
      <td><img src="PASTE_IMAGE_2_URL_HERE" width="100%" alt="Description 2" /></td>
      <td><img src="PASTE_IMAGE_3_URL_HERE" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

### Phase 2: Active Directory Installation & Forest Promotion
1. Utilized **Azure Bastion** to establish a secure browser-based administrative RDP session into `lab-vm` over port 443.
2. Installed the **Active Directory Domain Services** and **DNS Server** roles via Server Manager / PowerShell.
3. Promoted the server to a Domain Controller, creating a new root forest named `lab.local`.
4. Configured the Directory Services Restore Mode (DSRM) password and verified successful replication post-reboot.

<div align="center">
  <table>
    <tr>
      <td><img src="PASTE_IMAGE_1_URL_HERE" width="100%" alt="Description 1" /></td>
      <td><img src="PASTE_IMAGE_2_URL_HERE" width="100%" alt="Description 2" /></td>
      <td><img src="PASTE_IMAGE_3_URL_HERE" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

### Phase 3: Enterprise Organizational Unit (OU) Design
To prepare for scalable user and asset management, a structured OU hierarchy was designed and built to isolate administrative privileges and targets for Group Policy placement:

<div align="center">
  <table>
    <tr>
      <td><img src="PASTE_IMAGE_1_URL_HERE" width="100%" alt="Description 1" /></td>
      <td><img src="PASTE_IMAGE_2_URL_HERE" width="100%" alt="Description 2" /></td>
      <td><img src="PASTE_IMAGE_3_URL_HERE" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

```text
lab.local (Root)
│
└── 🏢 Enterprise-HQ
    ├── 📁 Groups (Security & Distribution groups)
    ├── 📁 Workstations (Corporate endpoint computer objects)
    ├── 📁 Servers (Member server objects)
    └── 📁 Staff (Standard user accounts)
        └── 👤 IT-Admin (Delegated administrative staff)

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
This lab lives inside the isolated `default` subnet established in [Lab 1](../Part1-Secure-Azure-Networking). Inbound network access is strictly locked down by `NSG-Identity`, and administrative management is performed exclusively via secure Azure Bastion proxies or authorized hosts in the management tier.

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
      <td><img src="https://github.com/user-attachments/assets/f3575497-c468-4a6f-a92f-94ce6f6de0d3" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/e00e0685-9a2d-4376-b100-372eab1ce205" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/7b40843f-041b-49bd-a4cd-9665f9bca60e" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

### 🌐 Architectural Decision Note: VNet-Level Custom DNS Routing

* **The Challenge:** Default cloud-provided DNS (Azure DNS) is blind to internal Active Directory environments, which causes client domain joins and authentication workflows to fail. 
* **The Solution:** Rather than manually overriding network adapter configurations inside individual guest operating systems (shown below), DNS routing was centralized at the cloud fabric layer by modifying `Vnet core` settings to utilize a custom DNS profile pointing directly to the Domain Controller (`lab-vm` at `10.0.0.4`).

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/2df8decb-775f-4b1d-bae7-c34dad46655d" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/8ed4a25d-0499-48b6-b5bc-5716466b304f" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/94bf339a-5b3d-465c-a344-74268a358165" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>

* **The Impact:** * **Automated Identity Discovery:** Azure automatically propagates the identity-aware DNS server to all current and future workloads via DHCP upon boot, ensuring seamless out-of-the-box domain resolution (joining client machines to domain).
* **Hybrid Resilience:** Configured upstream DNS Forwarders within the Windows Server DNS Manager, allowing internal assets to resolve local domain queries while securely routing external requests out to the public internet via the NAT Gateway.

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/d26544a5-63a5-415f-a6d6-027995b6da72" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/5c1abc39-a523-4f52-9c45-18dab297fea0" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/b294c5b0-f08f-476a-80fc-9b04171cc150" width="100%" alt="Description 3" /></td>
      <td><img src="https://github.com/user-attachments/assets/e88e24d1-1e20-4bb3-9b13-88ae21da57a3" width="100%" alt="Description 4" /></td>
      <td><img src="https://github.com/user-attachments/assets/4714b839-3c85-40ae-9101-7e4dee0f2ed5" width="100%" alt="Description 5" /></td>
      <td><img src="https://github.com/user-attachments/assets/9af73581-dcb0-4261-8f73-05f0df31eacc" width="100%" alt="Description 6" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
      <td align="center"><b>Label 4</b></td>
      <td align="center"><b>Label 5</b></td>
      <td align="center"><b>Label 6</b></td>
    </tr>
  </table>
</div>

```text
[Client PC] 
     │
  (DNS Query: Where is google.com?)
     ▼
[lab-vm (10.0.0.4)] ──(Doesn't know)──> [DNS Forwarder: 168.63.129.16 or 8.8.8.8] ──> [Internet via NAT Gateway]
```

---

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

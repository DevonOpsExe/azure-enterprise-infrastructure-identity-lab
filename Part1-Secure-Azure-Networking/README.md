# Lab 1: Cloud Infrastructure & Secure Networking Architecture

## 📌 Project Overview
This project focuses on the foundational phase of building an enterprise-grade cloud environment. It demonstrates the design, provisioning, and securing of an isolated virtual network architecture within Microsoft Azure. The infrastructure is engineered to mimic a secure corporate perimeter, serving as the network backbone for hosting enterprise services such as Active Directory Domain Services (AD DS).

---

## 🎯 Objectives
* Design and deploy a custom, multi-tier Azure Virtual Network (VNet).
* Enforce the principle of least privilege using Network Security Groups (NSGs).
* Implement secure remote access via a dedicated management subnet/host.
* Configure outbound connectivity for private assets using a NAT Gateway.

---

## 🛠️ Architecture & Components
The environment is structured into isolated subnets to ensure high security and clear separation of duties:

| Subnet Name | Address Space | Purpose | Security Profile |
| :--- | :--- | :--- | :--- |
| `Mgmt-Subnet` | `10.0.1.0/24` | Management & Jumpbox hosting | Restricted inbound SSH/RDP |
| `Identity-Subnet`| `10.0.2.0/24` | Core Active Directory infrastructure | Internal traffic only; No direct public IP |
| `Gateway-Subnet` | `10.0.3.0/24` | Future VPN/ExpressRoute integration | Perimeter boundary |



### Network Topography Map
```text
[Internet]
    │
    ▼ (Secure Administrative Access)
┌────────────────────────────────────────────────────────┐
│ Azure Virtual Network (10.0.0.0/16)                    │
│                                                        │
│  ┌──────────────────────┐      ┌────────────────────┐  │
│  │ Management Subnet    │      │ Identity Subnet    │  │
│  │ (10.0.1.0/24)        │      │ (10.0.2.0/24)      │  │
│  │                      │      │                    │  │
│  │ 🖥️ Jumpbox/Admin VM ──┼─────►│ 🖥️ Target Servers  │  │
│  └──────────────────────┘      └────────────────────┘  │
│             │                            ▲             │
│             ▼                            │             │
│       [NAT Gateway] ─────────────────────┘             │
│    (Secure Outbound Patches)                           │
└────────────────────────────────────────────────────────┘

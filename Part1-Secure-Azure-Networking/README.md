# Lab 1: Cloud Infrastructure & Secure Networking Architecture

## 📌 Project Overview
This project focuses on the foundational phase of building an enterprise-grade cloud environment. It demonstrates the design, provisioning, and securing of an isolated virtual network architecture within Microsoft Azure. The infrastructure is engineered to mimic a secure corporate perimeter, serving as the network backbone for hosting enterprise services such as Active Directory Domain Services (AD DS) and client endpoints.

---

## 🎯 Objectives
* Design and deploy a custom, multi-tier Azure Virtual Network (`Vnet core`).
* Enforce network micro-segmentation and the principle of least privilege using Network Security Groups (NSGs).
* Implement secure, modern remote administration utilizing Azure Bastion PaaS infrastructure.
* Configure secure outbound-only internet connectivity for private assets using a centralized NAT Gateway.

---

## 🛠️ Architecture & Components
The network architecture is structured into dedicated subnets within the **`rg-labtest-1`** resource group to ensure high security, strict traffic control, and clear isolation of server roles:

| Subnet Name | Address Space | Hosted Assets | Security Profile |
| :--- | :--- | :--- | :--- |
| `default` | `10.0.0.0/24` | 🖥️ Windows Server (Domain Controller) | Internal production traffic only; No direct public IPs |
| `Clientsubnet` | `10.0.2.0/24` | 🖥️ Client PC 1 <br> 🖥️ Client PC 2 | Isolated internal zone; Protected by strict firewall rules |
| `AzureBastionSubnet` | `10.0.1.0/26` | 🛡️ Azure Bastion Host (PaaS) | Locked down securely by Azure platform fabric |

### Network Topology Map
```text
![Lab Network Topology](https://i.imgur.com/a/RiMSKTO.jpg)

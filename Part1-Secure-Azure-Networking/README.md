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

---

### Network Topology Map

<img width="1408" height="768" alt="NetworkTopology " src="https://github.com/user-attachments/assets/772b7f9f-a71b-4cf4-96c1-d668bac3dda4" />

---

## 🚀 Implementation Steps

### Phase 1: Virtual Network & Subnet Provisioning
* **Resource Group:** Created a centralized container named `rg-labtest-1`.
* **Core VNet:** Configured `Vnet core` with a global address space of `10.0.0.0/16`.
* **Micro-Segmentation:** Segmented the network into three intentional subnets:
  * `default` (`10.0.0.0/24`) — Dedicated zone for identity servers.
  * `Clientsubnet` (`10.0.2.0/24`) — Secure zone for client workstations.
  * `AzureBastionSubnet` (`10.0.1.0/26`) — Reserved strictly for PaaS remote access.
<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/6d45da58-5467-43fa-be20-8aafb000c979" width="100%" alt="Description 1" /></td>
      <td><img src="https://github.com/user-attachments/assets/0911381b-f1c6-45fa-9204-7b22bc8eadb7" width="100%" alt="Description 2" /></td>
      <td><img src="https://github.com/user-attachments/assets/868def5b-b15b-4446-bb0d-881303befe40" width="100%" alt="Description 3" /></td>
    </tr>
    <tr>
      <td align="center"><b>Label 1</b></td>
      <td align="center"><b>Label 2</b></td>
      <td align="center"><b>Label 3</b></td>
    </tr>
  </table>
</div>
  

### Phase 2: Secure Remote Access (Azure Bastion)
* Deployed an Azure Bastion host into `AzureBastionSubnet` to eliminate the risk of exposing administrative ports (`3389`/`22`) to the public internet.
* All management sessions to the **Server** and **Client PCs** are securely proxied over **TLS/HTTPS (Port 443)** directly inside the Azure Web Portal.

### Phase 3: Network Security Hardening (NSGs)
Bound independent Network Security Groups (NSGs) to production subnets to enforce strict lateral isolation:
* **`NSG-Management` (Clientsubnet):** Configured to accept inbound connections **only** from the Bastion prefix (`10.0.1.0/26`). All unsolicited public internet ingress is implicitly dropped.
* **`NSG-Identity` (default Subnet):** Restricted inbound traffic on core infrastructure ports (`3389`, `389`, `445`, `135`) **strictly** to sources originating within `Clientsubnet` and `AzureBastionSubnet`. All other cross-subnet bypass paths are blocked.

### Phase 4: Enterprise Outbound Design (NAT Gateway)
* Provisioned a highly scalable Azure NAT Gateway tied to a static Public IP address.
* Associated the gateway with **both** `default` and `Clientsubnet` subnets, allowing private workloads to securely pull system updates and patches while maintaining an completely hidden inbound profile.

---

## 🔍 Verification & Testing

* **Perimeter Defense Check:** Direct RDP/SSH attempts from an external home network fail immediately, verifying that zero public entry paths exist.
* **Bastion Proxy Validation:** Confirmed stable, secure GUI administrative sessions to Client PC 1, Client PC 2, and the Server entirely via the browser interface.
* **Outbound Internet Check:** Executed a secure programmatic web request from the private server to verify outbound routing through the NAT Gateway.

---

## 💡 Key Takeaways & Skills Demonstrated

* **Micro-Segmentation:** Applied zero-trust architecture principles by explicitly isolating core identity components from standard management and client subnets.
* **PaaS Security Integration:** Engineered cloud perimeter protection using Azure Bastion, entirely removing internet-facing public IP vectors and traditional administrative attack surfaces.
* **Advanced NAT Design:** Implemented multi-subnet NAT binding to provide uniform, stateful outbound pathways for completely private multi-tier server architectures.
 
</div>

<div>
In Depth Technical Documentation: https://github.com/DevonOpsExe/azure-enterprise-infrastructure-identity-lab/blob/18d889e4d336ce8f7620f0d9456c45b93442df57/Part1-Secure-Azure-Networking/TechnicalDocumentation/README.md
Documentation by Devon Rice



  
</div>

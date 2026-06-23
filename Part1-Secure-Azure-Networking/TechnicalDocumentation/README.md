# 🚀 Engineering Implementation Blueprint: Lab 1

This document provides a rigorous, step-by-step breakdown of the engineering phases executed to establish the `rg-labtest-1` secure network perimeter.

---

## 🧭 Phase 1: Virtual Network & Subnet Segmentation

The objective of this phase was to build a secure, multi-tier network fabric that enforces strict isolation between different architectural roles (Identity, Management, and PaaS Remote Access).

### 1. Resource Group Provisioning
A logical container was established in the Azure subscription to organize and lifecycle-manage all lab infrastructure components:
* **Name:** `rg-labtest-1`
* **Region:** `[Your Selected Azure Region, e.g., East US]`

### 2. Core VNet Configuration
A Virtual Network was provisioned to act as the private network space for the entire enterprise lab topology:
* **Virtual Network Name:** `Vnet core`
* **Global IPv4 Address Space:** `10.0.0.0/16` (65,536 total addresses)

### 3. Subnet Micro-Segmentation
To eliminate a flat network architecture and restrict lateral movement vulnerabilities, the global address space was segmented into three functional subnets:

1. **`default` Subnet**
   * **CIDR Block:** `10.0.0.0/24` (251 usable IP addresses)
   * **Purpose:** Highly isolated tier reserved strictly for hosting identity providers and domain services.
2. **`Clientsubnet` Subnet**
   * **CIDR Block:** `10.0.2.0/24` (251 usable IP addresses)
   * **Purpose:** Functional zone for administrative workstations, jumpboxes, and client endpoints.
3. **`AzureBastionSubnet` Subnet**
   * **CIDR Block:** `10.0.1.0/26` (27 usable IP addresses)
   * **Purpose:** A dedicated, strictly reserved prefix required by the Azure Bastion PaaS infrastructure. *Note: Azure enforces severe restriction policies on this prefix; no standard virtual machines or custom NSGs can be associated here.*

---

## 🛡️ Phase 2: Secure Remote Access (Azure Bastion Deployment)

To defend against persistent internet-wide brute-force attacks and port scanning, public IP addresses were omitted from all lab virtual machines. Remote access was engineered using Azure Bastion as a managed, zero-trust proxy interface.

1. **PaaS Allocation:** An Azure Bastion instance was provisioned and bound directly to the `AzureBastionSubnet` (`10.0.1.0/26`).
2. **Public Endpoint:** A standard Azure Public IP address was assigned exclusively to the Bastion service. 
3. **Ingress Mechanics:** The Bastion host acts as an administrative ingress gateway. It listens externally on **TCP Port 443 (HTTPS)** inside the Azure Web Portal. When an administrator authenticates, Bastion proxies the session internally using native RDP (TCP 3389) or SSH (TCP 22) across the private backplane to the target private VMs.

---

## 🔒 Phase 3: Network Security Group (NSG) Hardening

Network Security Groups (NSGs) were deployed as stateful firewalls at the subnet level to explicitly define least-privilege traffic flow throughout the VNet.

```text
Traffic Flow Logic:
[Azure Portal / Web Browser] ──(HTTPS/443)──> [Azure Bastion Host]
                                                    │
                                      ┌─────────────┴─────────────┐
                               (RDP/3389)                  (RDP/3389)
                                      ▼                           ▼
                                [Clientsubnet] ──(AD Ports)─> [default Subnet]

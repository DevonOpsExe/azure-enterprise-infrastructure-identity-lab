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
Instead of manually clicking through Active Directory Users and Computers (ADUC) to create hundreds of corporate accounts, the automation pipeline reads raw data, sanitizes it, maps it to the target OU architecture, and provisions the assets programmatically.

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

---

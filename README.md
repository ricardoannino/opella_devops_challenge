# Opella DevOps Challenge

Azure Infrastructure Challenge: Reusable VNet Module
This repository contains a Terraform-based solution for provisioning a modular and scalable Azure environment. It demonstrates the use of a custom VNet module to deploy isolated environments (Development and Production) using a single-subscription, multi-resource-group strategy.

## 🏗 Architecture Overview
The project is structured to support environment parity while allowing for environment-specific configurations (such as IP addressing and VM sizing).

Custom VNet Module: A reusable component that handles VNet creation, dynamic subnetting via for_each, and basic security through Network Security Groups (NSG).

Environments: * Dev: Deployed to westeurope with a 10.10.0.0/16 address space.

Prod: (Configured for future scaling) using 10.20.0.0/16.

Compute: A Linux VM (Ubuntu 22.04) serves as the primary application host.

Storage: A Standard LRS Storage Account is included for diagnostic logging and persistent data.

## 📁 Repository Structure
.
├── modules/
│   └── vnet/               # Reusable Networking Module
│       ├── main.tf         # VNet, Subnets, and NSG logic
│       ├── variables.tf    # Module inputs (CIDR, RG Name, etc.)
│       └── outputs.tf      # Subnet IDs and VNet ID for downstream resources
├── main.tf                 # Root configuration (RG, VM, Storage)
├── variables.tf            # Global variables
├── outputs.tf              # Essential connection strings and IDs
├── backend.tf              # Remote state configuration (Azure Blob)
└── .github/workflows/      # CI/CD Pipeline (GitHub Actions)

## 🛠 Design Decisions & Justifications
1. Resource Groups vs. Subscriptions
For this challenge, I utilized Resource Groups to separate environments.

Reasoning: This approach is cost-effective and reduces management overhead for small-to-medium projects. It allows for environment-level RBAC and simplified lifecycle management (deleting a Resource Group cleans up the entire environment).

Scalability: For enterprise-scale "Landing Zones," I would recommend a Subscription-per-Environment model to avoid API rate limits and provide 100% blast-radius isolation.

2. Consistency & Maintenance (DRY)
I implemented a locals block in the root main.tf to manage a name_prefix and common_tags. This ensures that every resource follows a strict naming convention (e.g., opella-dev-vnet) and is easily trackable for billing and governance.

3. Security
The VNet module includes a default Network Security Group (NSG) that restricts inbound traffic. Associations are handled dynamically within the module to ensure no subnet is left "open" by default.

## 🚀 CI/CD Pipeline
The deployment is automated via GitHub Actions.

Branch Strategy: Pushes to develop trigger a plan and apply to the Dev environment. Pushes to main target the Production state.

State Management: Terraform state is stored securely in an Azure Blob Storage container, with unique keys for each environment to prevent state corruption.

## 📖 How to Use This Module
To use the VNet module in another project:

module "network" {
  source              = "./modules/vnet"
  vnet_name           = "my-app-vnet"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  subnets = {
    frontend = "10.0.1.0/24"
    backend  = "10.0.2.0/24"
  }
}

## Automation Tip
To automate documentation for this module, I recommend using terraform-docs. It can be integrated into the CI/CD pipeline to automatically update a README.md inside the module folder whenever variables change.
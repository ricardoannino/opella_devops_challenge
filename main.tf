# ------------------------------------------------------------------------------
# PROVISIONING: Opella Infrastructure
# Project: Challenge - VNet Module Implementation
# ------------------------------------------------------------------------------

locals {
  name_prefix = "opella-${var.environment}"
  common_tags = {
    Environment = var.environment
    Project     = "Infrastructure-Challenge"
    Owner       = "Platform-Team"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "./modules/vnet"
  environment         = var.environment
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  vnet_name     = "${local.name_prefix}-vnet"
  address_space = ["10.${var.environment == "dev" ? 10 : 20}.0.0/16"]

  subnets = {
    "snet-default" = "10.${var.environment == "dev" ? 10 : 20}.1.0/24"
    "snet-app"     = "10.${var.environment == "dev" ? 10 : 20}.2.0/24"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.name_prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["snet-default"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${local.name_prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Chosen for cost-effectiveness in Dev
  admin_username      = "opellaadmin"
  
  network_interface_ids = [azurerm_network_interface.nic.id]

  # For the challenge, using password auth (SSH keys preferred for prod)
  admin_password                  = "P@ssw0rd123456!" 
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_storage_account" "sa" {
  name                     = "opellastor${var.environment}001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = local.common_tags
}
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "mainrg" {
  name     = "learn-tf-rg-eastus"
  location = "East US"
}

# Create virtual network
resource "azurerm_virtual_network" "hubvnet" {
  name = "vnet-hub"
  location = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  address_space = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "mgmtsubnet" {
  name = "mgmt-subnet"
  resource_group_name = azurerm_resource_group.mainrg.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes = ["10.0.1.0/24"]
}

# Create a network interface
resource "azurerm_network_interface" "vm1-0" {
  name = "vm1-nic0"
  location = azurerm_resource_group.mainrg.location
  resource_group_name = azurerm_resource_group.mainrg.name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.mgmtsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create VM-1
resource "azurerm_windows_virtual_machine" "vm1" {
  name = "vm1"
  resource_group_name = azurerm_resource_group.mainrg.name
  location = azurerm_resource_group.mainrg.location
  size = "Standard_B1s"
  admin_username = "adminuser"
  admin_password = "SuperSecret@123!"
  network_interface_ids = [azurerm_network_interface.vm1-0.id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
}

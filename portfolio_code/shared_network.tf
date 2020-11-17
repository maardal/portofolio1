#Shared network infrastructure

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "sysAdm_portfolio1"
  location = var.azure_location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "sysAdmVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "sysAdmSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "sysAdmSG"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

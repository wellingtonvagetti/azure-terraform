# Deploy Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "RG-PRD01"
  location = "eastus2"

  tags = local.common_tags
}

# Deploy VNET
resource "azurerm_virtual_network" "vnet01" {
  name                = "vnet-prd01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["192.168.0.0/16"]
}

# Deploy VNET do Linux
resource "azurerm_virtual_network" "vnet02" {
  name                = "vnet-prd02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["172.16.0.0/16"]
}

# Deploy Subnet
resource "azurerm_subnet" "sub01" {
  name                 = "sub-prd01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["192.168.1.0/24"]
}

# Deploy Subnet do Linux
resource "azurerm_subnet" "sub02" {
  name                 = "sub-prd02"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet02.name
  address_prefixes     = ["172.16.0.0/24"]
}

# Associar NSG Subnet
resource "azurerm_subnet_network_security_group_association" "nsg01" {
  subnet_id                 = azurerm_subnet.sub01.id
  network_security_group_id = azurerm_network_security_group.nsg01.id
}

# Deploy NSG do Linux
resource "azurerm_network_security_group" "nsg02" {
  name                = "nsg-prd02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "172.16.0.0/24"
  }
}

# Associar NSG Subnet
resource "azurerm_subnet_network_security_group_association" "nsg02" {
  subnet_id                 = azurerm_subnet.sub02.id
  network_security_group_id = azurerm_network_security_group.nsg02.id
}

# Deploy Public IP Linux
resource "azurerm_public_ip" "pip02" {
  name                = "pip-vmlnx01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

# Deploy NIC VM Linux
resource "azurerm_network_interface" "vnic02" {
  name                = "nic-vm-lnx01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub02.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip02.id
  }
}
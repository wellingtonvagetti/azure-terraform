# Deploy Public IP
resource "azurerm_public_ip" "pip01" {
  name                = "pip-vmwin01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = local.common_tags
}

# Deploy NIC
resource "azurerm_network_interface" "vnic01" {
  name                = "nic-vm-win01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }

  tags = local.common_tags
}

# Deploy NSG
resource "azurerm_network_security_group" "nsg01" {
  name                = "nsg-prd01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "192.168.1.0/24"
  }
}

# Deploy VM
resource "azurerm_windows_virtual_machine" "vm01" {
  name                = "vm-win01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2S"
  admin_username      = "admin.terraform"
  admin_password      = "T3rr@f0rm2023"
  network_interface_ids = [
    azurerm_network_interface.vnic01.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

#DEPLOY VM LINUX
resource "azurerm_linux_virtual_machine" "vm02" {
  name                  = "vm-lnx01"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2S"
  admin_username        = "adminterraform"
  network_interface_ids = [azurerm_network_interface.vnic02.id]

  admin_ssh_key {
    username   = "adminterraform"
    public_key = file("./azure-key.pub")
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = local.common_tags
}
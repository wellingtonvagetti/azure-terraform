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
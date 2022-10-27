#########################################################
# Spoke VMs
#########################################################

# Webapp VM
resource "azurerm_network_interface" "webapp-vm-nic" {
  name                = "webapp-vm-ni01"
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.spoke-workload-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "webapp-vm" {
  name                              = "webapp-vm"
  resource_group_name               = azurerm_resource_group.spoke-rg.name
  location                          = azurerm_resource_group.spoke-rg.location
  size                              = var.vm_size
  admin_username                    = var.admin_username
  disable_password_authentication   = "false"
  admin_password                    = var.admin_password
  network_interface_ids             = [azurerm_network_interface.webapp-vm-nic.id]
  custom_data                       = base64encode(local.custom_data)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "webapp-vm-od01"
  }

  source_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }
}
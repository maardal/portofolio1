# Create a loadbalancer and n-number of virtual machines. Alo define ip and NIC.
resource "azurerm_public_ip" "lbIP" {
 name                         = "sysAdmPublicIPForLB"
 location                     = var.azure_location
 resource_group_name          = azurerm_resource_group.rg.name
 allocation_method            = "Static"
}

resource "azurerm_lb" "sysAdmLB" {
 name                = "sysAdmLoadBalancer"
 location            = var.azure_location
 resource_group_name = azurerm_resource_group.rg.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.lbIP.id
 }
}

resource "azurerm_lb_backend_address_pool" "sysAdmLbBackendPool" {
 resource_group_name = azurerm_resource_group.rg.name
 loadbalancer_id     = azurerm_lb.sysAdmLB.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "sysAdmVMNICS" {
 count               = var.instance_count
 name                = "acctni${count.index}"
 location            = var.azure_location
 resource_group_name = azurerm_resource_group.rg.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.subnet.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "sysADMVMDisks" {
 count                = var.instance_count
 name                 = "datadisk_existing_${count.index}"
 location             = var.azure_location
 resource_group_name  = azurerm_resource_group.rg.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "sysAdmAvset" {
 name                         = "avset"
 location                     = var.azure_location
 resource_group_name          = azurerm_resource_group.rg.name
 platform_fault_domain_count  = var.instance_count
 platform_update_domain_count = var.instance_count
 managed                      = true
}

resource "azurerm_virtual_machine" "sysAdmVMs" {
 count                 = var.instance_count
 name                  = "acctvm${count.index}"
 location              = var.azure_location
 availability_set_id   = azurerm_availability_set.sysAdmAvset.id
 resource_group_name   = azurerm_resource_group.rg.name
 network_interface_ids = [element(azurerm_network_interface.sysAdmVMNICS.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "datadisk_new_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "1023"
 }

 storage_data_disk {
   name            = element(azurerm_managed_disk.sysADMVMDisks.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.sysADMVMDisks.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.sysADMVMDisks.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = var.admin_username
   admin_password = var.admin_password
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "develop"
 }
}
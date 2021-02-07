########## build teh loadBalncer with VM in North Europe  ###########
resource "azurerm_resource_group" "gp_eastus" {
  name     = "gp_eastus"
  location = "eastus"
}

resource "azurerm_virtual_network" "eastus" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gp_eastus.location
  resource_group_name = azurerm_resource_group.gp_eastus.name
} 

resource "azurerm_subnet" "eastus" {
  name                 = "acctsub"
  resource_group_name  = azurerm_resource_group.gp_eastus.name
  virtual_network_name = azurerm_virtual_network.eastus.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "eastus" {
  name                         = "eastus"
  location                     = azurerm_resource_group.gp_eastus.location
  resource_group_name          = azurerm_resource_group.gp_eastus.name
  allocation_method            = "Static"
}

resource "azurerm_lb" "eastus" {
  name                = "LoadBalancer"
  location            = azurerm_resource_group.gp_eastus.location
  resource_group_name = azurerm_resource_group.gp_eastus.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.eastus.id
 }
}

resource "azurerm_lb_backend_address_pool" "eastus" {
  loadbalancer_id = azurerm_lb.eastus.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "eastus" {
 count               = 2
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.gp_eastus.location
 resource_group_name = azurerm_resource_group.gp_eastus.name

 ip_configuration {
   name                          = "eastusConfiguration"
   subnet_id                     = azurerm_subnet.eastus.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "eastus" {
 count                = 2
 name                 = "datadisk_existing_${count.index}"
 location             = azurerm_resource_group.gp_eastus.location
 resource_group_name  = azurerm_resource_group.gp_eastus.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "20"
}

resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.gp_eastus.location
 resource_group_name          = azurerm_resource_group.gp_eastus.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

resource "azurerm_virtual_machine" "eastus" {
 count                 = 2
 name                  = "acctvm${count.index}"
 location              = azurerm_resource_group.gp_eastus.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.gp_eastus.name
 network_interface_ids = [element(azurerm_network_interface.eastus.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04.0-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "eastusadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "targil"
 }
}
############ build teh loadBalncer with VM in North Europe  ################
resource "azurerm_resource_group" "gp_northeurope" {
  name     = "gp_northeurope"
  location = "northeurope"
}

resource "azurerm_virtual_network" "northeurope" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.gp_northeurope.location
  resource_group_name = azurerm_resource_group.gp_northeurope.name
} 

resource "azurerm_subnet" "northeurope" {
  name                 = "acctsub"
  resource_group_name  = azurerm_resource_group.gp_northeurope.name
  virtual_network_name = azurerm_virtual_network.northeurope.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "northeurope" {
  name                         = "northeurope"
  location                     = azurerm_resource_group.gp_northeurope.location
  resource_group_name          = azurerm_resource_group.gp_northeurope.name
  allocation_method            = "Static"
}

resource "azurerm_lb" "northeurope" {
  name                = "LoadBalancer"
  location            = azurerm_resource_group.gp_northeurope.location
  resource_group_name = azurerm_resource_group.gp_northeurope.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.northeurope.id
 }
}

resource "azurerm_lb_backend_address_pool" "northeurope" {
  loadbalancer_id = azurerm_lb.northeurope.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "northeurope" {
 count               = 2
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.gp_northeurope.location
 resource_group_name = azurerm_resource_group.gp_northeurope.name

 ip_configuration {
   name                          = "northeuropeConfiguration"
   subnet_id                     = azurerm_subnet.northeurope.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "northeurope" {
 count                = 2
 name                 = "datadisk_existing_${count.index}"
 location             = azurerm_resource_group.gp_northeurope.location
 resource_group_name  = azurerm_resource_group.gp_northeurope.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "20"
}

resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.gp_northeurope.location
 resource_group_name          = azurerm_resource_group.gp_northeurope.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

resource "azurerm_virtual_machine" "northeurope" {
 count                 = 2
 name                  = "acctvm${count.index}"
 location              = azurerm_resource_group.gp_northeurope.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.gp_northeurope.name
 network_interface_ids = [element(azurerm_network_interface.northeurope.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04.0-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "northeuropeadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "targil"
 }
}
##################  build the traffic manager  #########
resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}
##################  build the traffic manager  #########
resource "azurerm_traffic_manager_profile" "az_traffic" {
  name                   = random_id.server.hex
  resource_group_name    = azurerm_resource_group.gp_eastus.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = random_id.server.hex
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = "Targil"
  }
}

resource "azurerm_traffic_manager_endpoint" "eastus" {
  name                = random_id.server.hex
  resource_group_name = azurerm_resource_group.geastus.name
  profile_name        = azurerm_traffic_manager_profile.az_traffic.name
  target              = [azurerm_public_ip.northeurope.id,azurerm_public_ip.eastus.id]
  type                = "externalendpoint"
  weight              = 100
}
###########################
## Azure Nginx VM - Main ##
###########################


# Generate a random vm name
resource "random_string" "nginx-IM-vm-name" {
  length  = 8
  upper   = false
  numeric  = false
  lower   = true
  special = false
}

# Create Network Security Group
resource "azurerm_network_security_group" "nginx-IM-vm-nsg" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "nginx-${lower(var.environment)}-${random_string.nginx-IM-vm-name.result}-nsg"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  security_rule {
    name                       = "Allow-SSH"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    description                = "Allow HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags = {
    environment = var.environment
  }
}

# Associate the web NSG with the subnet
# resource "azurerm_subnet_network_security_group_association" "nginx-IM-vm-nsg-association" {
#   depends_on=[azurerm_resource_group.network-rg]

#   subnet_id                 = azurerm_subnet.vm-subnet.id
#   network_security_group_id = azurerm_network_security_group.nginx-IM-vm-nsg.id
# }

# Get a Static Public IP
resource "azurerm_public_ip" "nginx-IM-vm-ip" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "nginx-${random_string.nginx-IM-vm-name.result}-ip"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  allocation_method   = "Static"
  
  tags = { 
    environment = var.environment
  }
}

# Create Network Card for the VM
resource "azurerm_network_interface" "nginx-IM-nic" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "nginx-${random_string.nginx-IM-vm-name.result}-nic"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nginx-IM-vm-ip.id
  }

  tags = { 
    environment = var.environment
  }
}


# Cloud config configuration
data "template_file" "IMcloudconfig" {
  template = file("${path.module}/cloudInitFiles/cloud-init_nginxIM.tpl")

}

data "template_cloudinit_config" "IMconfig" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.IMcloudconfig.rendered
  }
}

# Create Nginx VM
resource "azurerm_linux_virtual_machine" "nginx-IM-vm" {
  depends_on=[azurerm_network_interface.nginx-IM-nic]

  name                  = "nginx-IM-${random_string.nginx-IM-vm-name.result}-vm"
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  network_interface_ids = [azurerm_network_interface.nginx-IM-nic.id]
  size                  = var.nginx_vm_size

 #nginxinc:nginx-plus-ent-v1:nginx-plus-ent-un1804:7.0.0
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # plan {
  #   name      = "22_04-lts-ARM"
  #   publisher = "Canonical"
  #   product   = "0001-com-ubuntu-server-jammy"
  # }

  os_disk {
    name                 = "nginx-IM-${random_string.nginx-IM-vm-name.result}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "nginx-IM-${random_string.nginx-IM-vm-name.result}-vm"
  admin_username = var.nginx_admin_username
  admin_password = var.nginx_admin_password
  custom_data    = "${data.template_cloudinit_config.IMconfig.rendered}"

  disable_password_authentication = false

  tags = {
    environment = var.environment
  }
}

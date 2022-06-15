###########################
## Azure Nginx VM - Main ##
###########################


# Generate a random vm name
resource "random_string" "nginx-vm-name" {
  length  = 8
  upper   = false
  numeric  = false
  lower   = true
  special = false
}

# Create Network Security Group
resource "azurerm_network_security_group" "nginx-vm-nsg" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "nginx-${lower(var.environment)}-${random_string.nginx-vm-name.result}-nsg"
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
    name                       = "Allow-HTTP"
    description                = "Allow HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
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
resource "azurerm_subnet_network_security_group_association" "nginx-vm-nsg-assoc" {
  depends_on=[azurerm_resource_group.network-rg]

  subnet_id                 = azurerm_subnet.vm-subnet.id
  network_security_group_id = azurerm_network_security_group.nginx-vm-nsg.id
}

# Get a Static Public IP
resource "azurerm_public_ip" "nginx-vm-ip" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "nginx-${random_string.nginx-vm-name.result}-ip"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  allocation_method   = "Static"
  
  tags = { 
    environment = var.environment
  }
}

# Create Network Card for the VM
resource "azurerm_network_interface" "nginx-nic" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "nginx-${random_string.nginx-vm-name.result}-nic"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nginx-vm-ip.id
  }

  tags = { 
    environment = var.environment
  }
}


# Create Nginx VM
resource "azurerm_linux_virtual_machine" "nginx-vm" {
  depends_on=[azurerm_network_interface.nginx-nic]

  name                  = "nginx-${random_string.nginx-vm-name.result}-vm"
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  network_interface_ids = [azurerm_network_interface.nginx-nic.id]
  size                  = var.nginx_vm_size

 #nginxinc:nginx-plus-ent-v1:nginx-plus-ent-un1804:7.0.0
  source_image_reference {
    publisher = "nginxinc"
    offer     = "nginx-plus-ent-v1"
    sku       = "nginx-plus-ent-un1804"
    version   = "7.0.0"
  }

  plan {
    name      = "nginx-plus-ent-un1804"
    publisher = "nginxinc"
    product   = "nginx-plus-ent-v1"
  }

  os_disk {
    name                 = "nginx-${random_string.nginx-vm-name.result}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "nginx-${random_string.nginx-vm-name.result}-vm"
  admin_username = var.nginx_admin_username
  admin_password = var.nginx_admin_password

  disable_password_authentication = false

  tags = {
    environment = var.environment
  }
}

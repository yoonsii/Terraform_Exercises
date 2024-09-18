provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = var.subscription_id
}

# Reference to the existing resource group (parameterized)
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Create a Public IP Address for the VM
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = ["10.0.0.0/16"]
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Network Security Group with SSH and HTTP rules
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a Network Interface with a Public IP
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Associate NSG with the network interface of the VM
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Create a Linux VM in the existing resource group
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                = "Standard_DS1_v2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  # Use cloud-init to install Apache (base64-encoded)
  custom_data = base64encode(<<EOF
#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
EOF
  )
}

# Output the Public IP address
output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "9734ed68-621d-47ed-babd-269110dbacb1"
  resource_provider_registrations = "none"
}

# Use existing sandbox resource group
data "azurerm_resource_group" "rg" {
  name = "1-8c09cea5-playground-sandbox"
}

# Create MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "mysqltestflex"
  location               = data.azurerm_resource_group.rg.location
  resource_group_name    = data.azurerm_resource_group.rg.name
  administrator_login    = "yoonsi"
  administrator_password = "MySecurePassw0rd!"  # Must be strong
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  zone                   = "1"
}

# Create a test database
resource "azurerm_mysql_flexible_database" "nxcdb1" {
  name                = "nxcdb1"
  server_name         = azurerm_mysql_flexible_server.mysql.name
  resource_group_name = data.azurerm_resource_group.rg.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}


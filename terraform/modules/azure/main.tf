terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
  }
}

variable "prefix" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "lake" {
  name                     = replace("${var.prefix}lake", "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_container" "raw" {
  name                 = "raw"
  storage_account_name = azurerm_storage_account.lake.name
}

output "lake_account" { value = azurerm_storage_account.lake.name }

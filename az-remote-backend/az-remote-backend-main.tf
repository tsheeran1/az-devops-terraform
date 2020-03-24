provider "random" {
  version = "~>2.2"
}

provider "azurerm" {
    version = "~>2.0"
    features {}
}

# Generate a random storage name
resource "random_uuid" "tf-ID" {}

# Create a Resource Group for the Terraform State File
resource "azurerm_resource_group" "state-rg" {
  name = "${lower(var.company)}-tfstate-rg"
  location = var.location
  
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    environment = var.environment
  }
}
# Create a Storage Account for the Terraform State File
resource "azurerm_storage_account" "state-sta" {
  depends_on = [azurerm_resource_group.state-rg]
  name = substr("${lower(var.company)}${replace(random_uuid.tf-ID.result,"-","")}",0,23)
  resource_group_name = azurerm_resource_group.state-rg.name
  location = azurerm_resource_group.state-rg.location
  account_kind = "StorageV2"
  account_tier = "Standard"
  access_tier = "Hot"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
   
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    environment = var.environment
  }
}
# Create Soft Delete policy for the above container
resource "azurerm_storage_management_policy" "soft-delete" {
  storage_account_id = azurerm_storage_account.state-sta.id
  rule {
    name = "softDeleteRule"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 10
        tier_to_archive_after_days_since_modification_greater_than = 365
        delete_after_days_since_modification_greater_than = 180
      }
    }
  }
}

# Create a Storage Container for the Core State File
resource "azurerm_storage_container" "core-container" {
  depends_on = [azurerm_storage_account.state-sta]
  name = "core-tfstate"
  storage_account_name = azurerm_storage_account.state-sta.name
}
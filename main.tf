provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "examplenes1" {
  name     = "rg-appfunction"
  location = "West Europe"
}

resource "azurerm_virtual_network" "examplenes1" {
  name                = "vnet-appfunction"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.examplenes1.location
  resource_group_name = azurerm_resource_group.examplenes1.name
}

resource "azurerm_subnet" "examplenes1" {
  name                 = "subnet-appfunction"
  resource_group_name  = azurerm_resource_group.examplenes1.name
  virtual_network_name = azurerm_virtual_network.examplenes1.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation-appfunction"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}



resource "azurerm_storage_account" "examplenes1" {
  name                     = "storageaccappfunction"
  resource_group_name      = azurerm_resource_group.examplenes1.name
  location                 = azurerm_resource_group.examplenes1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


dynamic "network_rules" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action             = "Deny"
      bypass                     = ["AzureServices"]
      ip_rules                   = ["123.201.18.148"]
      virtual_network_subnet_ids = ["10.0.1.0/24"]
    }
}
}
resource "azurerm_app_service_plan" "app_ser_plan" {
  name                = "serviceplan-appfunc"
  resource_group_name      = azurerm_resource_group.examplenes1.name
  location                 = azurerm_resource_group.examplenes1.location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                        = "appfunctestprivatenet"
  resource_group_name      = azurerm_resource_group.examplenes1.name
  location                 = azurerm_resource_group.examplenes1.location
  app_service_plan_id        = azurerm_app_service_plan.app_ser_plan.id
  //https_only                 = var.https_only
  storage_account_name       = azurerm_storage_account.examplenes1.name
  storage_account_access_key = azurerm_storage_account.examplenes1.secondary_access_key 
  


dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
  dynamic "identity" {
    for_each = var.identity[*]
    content {
      type         = lookup(identity.value, "type", null)
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }
 
  dynamic "site_config" {
    for_each = var.site_config[*]
    iterator = each
    content {
      //numberOfWorkers          = lookup(each.value, "numberofworkers", null)
      //app_command_line         = lookup(each.value, "app_command_line", null)
      //default_documents        = lookup(each.value, "default_documents", null)
      dotnet_framework_version = lookup(each.value, "dotnet_framework_version", null)
      //local_mysql_enabled      = lookup(each.value, "local_mysql_enabled", null)
      linux_fx_version         = lookup(each.value, "linux_fx_version", null)
    //  windows_fx_version       = lookup(each.value, "windows_fx_version", null)
     // managed_pipeline_mode    = lookup(each.value, "managed_pipeline_mode", null)

    }
  }


 
}

resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_function_app.function_app.id
  subnet_id      = azurerm_subnet.examplenes1.id
  //var.app_sub_net
}
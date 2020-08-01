resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "this" {
  name                = "appingt-${var.function_app_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "this" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "FunctionApp"

  sku {
    tier = var.app_service_plan_sku
    size = var.app_service_plan_size
  }
}

resource "azurerm_function_app" "this" {
  name                      = var.function_app_name
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  app_service_plan_id       = azurerm_app_service_plan.this.id
  storage_connection_string = azurerm_storage_account.this.primary_connection_string
  version                   = "~3"

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.this.instrumentation_key
  }

  auth_settings {
    enabled                       = false
    unauthenticated_client_action = "AllowAnonymous"
  }
}
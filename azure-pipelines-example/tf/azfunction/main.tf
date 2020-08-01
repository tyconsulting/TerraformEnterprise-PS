module "azure_function" {
    source = "./modules/terraform-azurerm-function-app"

    resource_group_name = var.resource_group_name
    location = var.location
    storage_account_name = var.storage_account_name
    app_service_plan_name = var.app_service_plan_name
    app_service_plan_sku = var.app_service_plan_sku
    app_service_plan_size = var.app_service_plan_size
    function_app_name = var.function_app_name
}
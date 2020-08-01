
output "function_app_object" {
    description = "Function App"
    value = module.azure_function.object
}

output "function_app_id" {
    description = "Function App Id"
    value = module.azure_function.id
}

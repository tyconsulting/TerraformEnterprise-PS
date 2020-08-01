output "id" {
    description = "Function App Id"
    value = azurerm_function_app.this.id
}

output "object" {
    description = "The function app object"
    value = azurerm_function_app.this
}

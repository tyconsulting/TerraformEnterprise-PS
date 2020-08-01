variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
    default = "australiaeast"
}

variable "storage_account_name" {
    type = string
}

variable "app_service_plan_name" {
    type = string
}

variable "app_service_plan_sku" {
    type = string
    default = "Dynamic"
}

variable "app_service_plan_size" {
    type = string
    default = "Y1"
}

variable "function_app_name" {
    type = string
}

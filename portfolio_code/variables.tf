variable "azure_location" {
    description = "Azure Location"
    type = string
    default = "westus2"
}

variable "instance_count" {
    description = "Number of instances to provision"
    type = number
    default = 2
}

variable "admin_username" {
    description = "Username for admin user"
    type = string
    default = "testadmin"
}

variable "admin_password" {
    description = "Password for admin user"
    type = string
    default = "Password1234!"
}
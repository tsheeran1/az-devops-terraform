# company
variable "company" {
  type = string
  default = "tsheeran"
}
# environment
variable "environment" {
  type = string
  default = "az-devops-example-backend"
}
# azure region
variable "location" {
  type = string
  description = "Azure region where resources will be created"
  default = "Central US"
}
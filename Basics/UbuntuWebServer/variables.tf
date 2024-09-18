variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "yoonsi"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM"
  default     = "DeathPass1!"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID of the sandbox environment"
}

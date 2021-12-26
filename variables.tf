variable "network_rules" {
  description = "Network rules restricting access to the storage account."
  type = object({
    ip_rules   = list(string)
    subnet_ids = list(string)
    bypass     = list(string)
  })
  default = null
}

variable "connection_strings" {
  default = {}
}
variable "identity" {
  description = "Type of Managed Identity which should be assigned to the virtual machine. Possible values are SystemAssigned, UserAssigned, and SystemAssigned, UserAssigned"
  
    
  default = null
}
variable "site_config" {
  default = null
}
variable "app_settings" {
  default = null
}
                                     
variable "slots" {
  default = {}
}

variable "application_insight" {
  default = null
}

#variable "base_tags" {}


variable "combined_objects" {
  default = {}
}


variable "framework" {

  default = null
}

variable "workers" {
  default = null
}



variable "dynamic_app_settings" {
  default = {}
}
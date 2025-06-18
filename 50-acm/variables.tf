variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"

}

variable "zone_name" {
  default = "hraje.online"

}

variable "zone_id" {
  default = "Z10066791KNE051XOLV0F"

}



variable "common_tags" {
  default = {
    Project     = "expense"
    Terraform   = "true"
    Environment = "dev"
  }
}


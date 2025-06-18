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
  default = "Z03194511OQOLMFG3BETC"

}



variable "common_tags" {
  default = {
    Project     = "expense"
    Terraform   = "true"
    Environment = "dev"
  }
}


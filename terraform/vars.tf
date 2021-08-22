variable "vpc" {
        default = "vpc-3239444f"
}

variable "ssh_private_key" {
  default = "C:/Users/user/.ssh/gaby_pri"
}

variable "key_name" {
  default = "mykey"
}

variable "public_key_path" {
  default = "./"
}

variable "private_key_path" {
  default = "/C:/Users/user/.ssh/gaby_pri"
}

variable "ami" {
  default = "ami-04bdd81ca5f1191d5"
}
variable "domain" {
    default = "gaby-es"
}

variable "instance_type" {
    default = "t3.small.elasticsearch"
    type = string

}
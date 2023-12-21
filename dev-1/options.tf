variable "private_key_local_path" {
  type    = string
  default = "path_to_key"
}

variable "aws_key_pair" {
  type    = string
  default = "key"
}

variable "environment_name" {
  type    = string
  default = "Dev"
}

variable "asterisk_version" {
  type    = string
  default = "21"
}

variable "node_version" {
  type    = string
  default = "20.10.0"
}

variable "endpoint_passwords" {
  type = map(string)
  default = {
    phone_01 = "changeme"
    phone_02 = "changeme"
    phone_03 = "changeme"
  }
}

variable "ari_password" {
  type    = string
  default = "changeme"
}

variable "domain_name" {
  type    = string
  default = "domainName.com"
}

variable "domain_contact_mail" {
  type    = string
  default = "your-email"
}

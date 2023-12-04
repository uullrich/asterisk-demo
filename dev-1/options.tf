variable "private_key_local_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "aws_key_pair" {
  type    = string
  default = "uullrich_key"
}

variable "environment_name" {
  type    = string
  default = "Dev"
}

variable "asterisk_version" {
  type    = string
  default = "21"
}

variable "region" {
    default = "europe-west2"
}

variable "zone" {
    default = "europe-west2-a"
}

variable "project" {
    default = "devserver"
}

variable "user" {
    type = string
}

variable "email" {
    type = string
}
variable "privatekeypath" {
    type = string
    default = "~/.ssh/id_rsa"
}

variable "publickeypath" {
    type = string
    default = "~/.ssh/id_rsa.pub"
}
variable "name_prefix" {
  description = "Prefix for network resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 /16 network range for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be a valid IPv4 /16 CIDR, for example 10.20.0.0/16."
  }
}

variable "availability_zones" {
  description = "Two distinct Availability Zones for the network."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Provide exactly two distinct Availability Zones."
  }
}

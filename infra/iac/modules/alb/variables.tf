variable "name" {
  type = string
}

variable "idle_timeout" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "target_type" {
  type = string
}

variable "health_check_path" {
  type = string
}
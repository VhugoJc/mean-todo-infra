variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "ingress_rules" {
  description = "Lista de reglas de ingreso"
  type        = list(string)
  default     = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
}

variable "ingress_cidr_blocks" {
  description = "Bloques CIDR para ingreso"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_rules" {
  description = "Lista de reglas de egreso"
  type        = list(string)
  default     = ["all-all"]
}

variable "egress_cidr_blocks" {
  description = "Bloques CIDR para egreso"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

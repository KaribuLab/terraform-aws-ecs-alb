variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "ecs-alb"
}

variable "alb_internal" {
  description = "Whether the ALB is internal or external"
  type        = bool
  default     = false
}

variable "alb_deletion_protection_enabled" {
  description = "Whether the ALB deletion protection is enabled"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ALB will be deployed"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "idle_timeout" {
  description = "Tiempo de espera en segundos para conexiones inactivas (para evitar errores 504)"
  type        = number
  default     = 60
}

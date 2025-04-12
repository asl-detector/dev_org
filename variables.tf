variable "project_name" {
  description = "Project name"
  type        = string
  default     = "data-science"
}

variable "vpc_id" {
  description = "VPC ID where SageMaker will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where SageMaker will be deployed"
  type        = list(string)
}

variable "data_scientist_users" {
  description = "List of data scientist usernames to create"
  type        = list(string)
  default     = ["analyst1", "analyst2"]
}

variable "uuid" {
  description = "UUID for the artifact account"
  type        = string
}

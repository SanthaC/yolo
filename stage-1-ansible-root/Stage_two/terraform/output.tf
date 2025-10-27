# AWS region variable
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# Ansible inventory file path
variable "ansible_inventory" {
  description = "Path to the Ansible inventory file used for provisioning"
  type        = string
  default     = "./inventory.ini"
}

# Ansible playbook file path
variable "ansible_playbook" {
  description = "Path to the Ansible playbook file executed"
  type        = string
  default     = "./playbook.yml"
}